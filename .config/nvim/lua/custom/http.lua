-- Other plugins for inspiration:
-- https://github.com/darrenburns/posting
-- https://github.com/mistweaverco/kulala.nvim
-- https://github.com/oysandvik94/curl.nvim

-- More information about the syntax:
-- https://www.jetbrains.com/help/idea/exploring-http-syntax.html

local String = require("custom.string")
local fs = require("custom.fs")

---@class Request
---@field ok boolean
---@field method string|nil
---@field url string|nil
---@field headers table
---@field body string
---@field curl_cmd string[]
---@filed http_version string|nil

---@class Response
---@field status integer
---@field headers table
---@field filename string|nil
---@field body string

---@class RequestView
---@field request Request
---@field response Response

---@class ParseOptions
---@field shell boolean

local M = {}

local state = {
    cookie = nil,
    env = {
        available = nil,
        selected = "dev",
    },
    cache = {},
    window_id = -1,
    buffer_id = -1,
}

local parse_stages = {
    METHOD_URL = "method_url",
    HEADERS = "headers",
    BODY = "body",
}

local READ_ONLY = 00444 -- `:Man 2 open`

local function read_env()
    if state.env.available ~= nil then
        return
    end

    local env_file_names = { "http-client.private.env.json", "http-client.env.json" }
    local env_file_name = nil
    local env_dir = nil

    for _, file in ipairs(env_file_names) do
        local dir = fs.root_files({ file })

        if dir ~= nil then
            env_file_name = file
            env_dir = dir
            break
        end
    end

    if env_dir == nil then
        vim.notify("Unable to find environment file.", vim.log.levels.ERROR)
        return
    end

    local env_path = env_dir .. "/" .. env_file_name
    local stat = vim.uv.fs_stat(env_path)

    if stat == nil or stat.type ~= "file" then
        vim.notify("Expected an environment file.", vim.log.levels.ERROR)
        return
    end

    local fd, open_err, open_err_name = vim.uv.fs_open(env_path, "r", READ_ONLY)

    if not fd then
        vim.notify(
            "Error opening env file " .. " (" .. open_err_name .. "): " .. open_err,
            vim.log.levels.ERROR
        )
        return
    end

    local data, read_err, read_err_name = vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)

    if not data then
        vim.notify(
            "Error reading env file " .. " (" .. read_err_name .. "): " .. read_err,
            vim.log.levels.ERROR
        )
        return
    end

    local ok, json_value = pcall(vim.json.decode, data)
    if not ok then
        vim.notify("Error parsing env file.", vim.log.levels.ERROR)
        return
    end

    state.env.available = json_value
end

local function toggle_floating_window()
    if vim.api.nvim_win_is_valid(state.window_id) then
        return
    end

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    if not vim.api.nvim_buf_is_valid(state.buffer_id) then
        state.buffer_id = vim.api.nvim_create_buf(false, true)
    end

    state.window_id = vim.api.nvim_open_win(state.buffer_id, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        noautocmd = true,
        style = "minimal",
        border = "single",
    })

    vim.bo[state.buffer_id].buftype = "nofile"
    vim.bo[state.buffer_id].swapfile = false
    vim.bo[state.buffer_id].filetype = "markdown"

    vim.api.nvim_win_set_cursor(state.window_id, { 1, 0 })

    vim.keymap.set("n", "<C-C>", function()
        vim.api.nvim_win_hide(state.window_id)
        state.window_id = -1
    end, { buffer = state.buffer_id, noremap = true })
end

---@param headers table
---@param name string
---@return string[]|nil
local function get_header(headers, name)
    if headers[name] then
        return headers[name]
    end

    local lower_name = name:lower()
    for k, v in pairs(headers) do
        if k:lower() == lower_name then
            return v
        end
    end

    return nil
end

---@param content_type string
---@return string
local function get_mime_type(content_type)
    local mime_type = content_type:match("^([^;]+)")

    if mime_type then
        mime_type = mime_type:match("^%s*(.-)%s*$"):lower()
    else
        mime_type = content_type:lower()
    end

    return mime_type
end

---@param value string
---@return string[]
local function format_json(value)
    local job = vim.system({ "jq", "." }, { text = true, stdin = value })
    local result = job:wait()

    if result.code ~= 0 then
        return vim.split(value, "\n", { plain = true })
    end

    return vim.split(result.stdout, "\n", { plain = true })
end

---@param mime_type string|nil
---@return string|nil
local function get_file_extension(mime_type)
    if not mime_type or mime_type == "" then
        return nil
    end

    if mime_type == "application/pdf" then
        return "pdf"
    end

    if mime_type == "application/zip" then
        return "zip"
    end

    if mime_type == "application/xml" or mime_type == "text/xml" then
        return "xml"
    end

    if mime_type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then
        return "xlsx"
    end

    if mime_type == "text/csv" then
        return "csv"
    end

    if mime_type == "image/svg+xml" then
        return "svg"
    end

    return nil
end

---@param cookie string
---@return string
local function get_cookie_value(cookie)
    return String.split(cookie, ";")[1]
end

---@param mime_type string
---@param content string
---@param filename string|nil
---@return string[]
local function format_lines(mime_type, content, filename)
    if mime_type == "application/json" then
        return format_json(content)
    end

    -- TODO: Handle "text/html" responses

    local extension = get_file_extension(mime_type)

    if extension ~= nil then
        local tmpdir = vim.uv.os_tmpdir()
        local name = filename or ("curl_response_" .. String.random_word(5) .. "." .. extension)
        local filepath = fs.join_paths(tmpdir, name)
        fs.write_file(filepath, content, false, true)
        return { filepath }
    end

    -- TODO: Return body split by newline
    return {}
end

---@param mime_type string|nil
---@return string
local function get_code_block_type(mime_type)
    if not mime_type or mime_type == "" then
        return ""
    end

    if mime_type == "application/json" then
        return "json"
    end

    if mime_type == "text/html" then
        return "html"
    end

    return ""
end

---@param headers table
---@return string[]
local function format_headers(headers)
    local ok, json_str = pcall(vim.json.encode, headers)

    if not ok then
        vim.notify("Unable to format headers.", vim.log.levels.ERROR)
        return { "" }
    end

    return format_json(json_str)
end

---@param request_view RequestView
local function render_markdown(request_view)
    local output = {}
    local request, response = request_view.request, request_view.response

    local req_content_type = get_header(request.headers, "Content-Type")
    local req_body_mime_type = get_mime_type(req_content_type and req_content_type[1] or "")

    local res_content_type = get_header(response.headers, "Content-Type")
    local res_body_mime_type = get_mime_type(res_content_type and res_content_type[1] or "")

    table.insert(output, "# HTTP RESULT")
    table.insert(output, "")

    -- Request
    table.insert(output, "## REQUEST URL")
    table.insert(output, "")
    table.insert(output, "```")
    table.insert(output, request.method .. " " .. request.url)
    table.insert(output, "```")
    table.insert(output, "")

    if next(request.headers) ~= nil then
        table.insert(output, "## REQUEST HEADERS")
        table.insert(output, "")
        table.insert(output, "```json")
        vim.list_extend(output, format_headers(request.headers))
        table.insert(output, "```")
        table.insert(output, "")
    end

    if #request.body ~= 0 then
        table.insert(output, "## REQUEST BODY")
        table.insert(output, "")
        table.insert(output, "```" .. get_code_block_type(req_body_mime_type))
        vim.list_extend(output, format_lines(req_body_mime_type, request.body, nil))
        table.insert(output, "```")
        table.insert(output, "")
    end

    -- Response
    table.insert(output, "## RESPONSE CODE")
    table.insert(output, "")
    table.insert(output, "`" .. tostring(response.status) .. "`")
    table.insert(output, "")

    table.insert(output, "## RESPONSE HEADERS")
    table.insert(output, "")
    table.insert(output, "```json")
    vim.list_extend(output, format_headers(response.headers))
    table.insert(output, "```")
    table.insert(output, "")

    table.insert(output, "## RESPONSE BODY")
    table.insert(output, "")
    table.insert(output, "```" .. get_code_block_type(res_body_mime_type))
    vim.list_extend(output, format_lines(res_body_mime_type, response.body, response.filename))
    table.insert(output, "```")

    vim.api.nvim_buf_set_lines(state.buffer_id, 0, -1, false, output)
end

---Splits raw curl -i output into headers string and body string
---@param raw string
---@return string header_str, string body_str
local function split_response(raw)
    local pos = 1
    local header_str = ""
    local body_str = ""

    while true do
        local s, e = raw:find("\r?\n\r?\n", pos)
        if not s then
            header_str = raw
            body_str = ""
            break
        end

        local rest = raw:sub(e + 1)
        if rest:match("^HTTP/%d") then
            pos = e + 1
        else
            header_str = raw:sub(pos, s - 1)
            body_str = rest
            break
        end
    end

    return header_str, body_str
end

---@param request Request
---@param response vim.SystemCompleted
local function process_response(request, response)
    if not request.url or not request.method then
        return
    end

    if response.code ~= 0 then
        vim.notify("There has been an error.", vim.log.levels.ERROR)
        vim.print(response.stderr)
        return
    end

    if not response.stdout then
        vim.notify("No response received.", vim.log.levels.ERROR)
        return
    end

    vim.notify("Parsing response...", vim.log.levels.INFO)

    local header_str, body_str = split_response(response.stdout)

    local status = -1
    local headers = {}
    local header_lines = header_str:gmatch("[^\r\n]+")
    for line in header_lines do
        if vim.startswith(line, "HTTP") then
            local parsed_status = line:match("HTTP/[%d%.]+%s*(%d+)")
            status = parsed_status ~= nil and tonumber(parsed_status) or -1
            goto continue
        end

        local key, value = line:match("^([^:]+):%s*(.-)%s*$")
        if key and value then
            if headers[key] ~= nil then
                table.insert(headers[key], value)
            else
                headers[key] = { value }
            end
        end

        ::continue::
    end

    local set_cookie = get_header(headers, "Set-Cookie")
    if set_cookie then
        state.cookie = state.cookie ~= nil and state.cookie or {}

        for _, cookie in ipairs(set_cookie) do
            local cookie_pair = String.split(get_cookie_value(cookie), "=")
            state.cookie[cookie_pair[1]] = cookie_pair[2]
        end
    end

    local filename = nil
    local cd = get_header(headers, "Content-Disposition")
    if cd and cd[1] then
        filename = cd[1]:match("filename%*%s*=%s*[^%s\039;]+%s*\039\039%s*([^%s;]+)")
        if not filename then
            filename = cd[1]:match('filename%s*=%s*"([^"]+)"')
        end
        if not filename then
            filename = cd[1]:match("filename%s*=%s*([^%s;]+)")
        end
    end

    ---@type RequestView
    local request_view = {
        request = request,
        response = {
            status = status,
            headers = headers,
            filename = filename,
            body = body_str,
        },
    }

    state.cache[request.url] = state.cache[request.url] or {}
    state.cache[request.url][request.method] = request_view

    toggle_floating_window()

    render_markdown(request_view)

    vim.notify("Response parsed!", vim.log.levels.INFO)
end

---@param request Request
local function execute_curl(request)
    if vim.fn.executable("curl") == 0 then
        vim.notify("Can't find curl executable.", vim.log.levels.ERROR)
        return
    end

    vim.notify("Making HTTP request...", vim.log.levels.INFO)

    vim.system(request.curl_cmd, { text = false }, function(response)
        vim.schedule(function()
            process_response(request, response)
        end)
    end)
end

---@param options ParseOptions
---@return Request
local function parse_request(options)
    ---@type Request
    local request = {
        ok = false,
        method = nil,
        url = nil,
        http_version = nil,
        headers = {},
        body = "",
        curl_cmd = {},
    }

    local ft = vim.bo.filetype
    if ft ~= "http" then
        vim.notify("Expected the HTTP request to be in an http filetype", vim.log.levels.ERROR)
        return request
    end

    -- TODO: Support to be able to have the cursor in any place of the request

    -- TODO: Support uploading files using "multipart/form-data":
    --       https://www.jetbrains.com/help/idea/exploring-http-syntax.html#use-multipart-form-data

    -- Cursor is expected to be at the first line of the HTTP request
    local cursor = vim.api.nvim_win_get_cursor(0)
    local start_line = cursor[1]
    local total_lines = vim.api.nvim_buf_line_count(0)

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, total_lines, false)
    if not lines or #lines == 0 then
        vim.notify("No lines in current buffer to parse", vim.log.levels.ERROR)
        return request
    end

    local parse_stage = parse_stages.METHOD_URL

    -- More information about lua patterns:
    -- https://www.lua.org/pil/20.2.html
    for _, line in ipairs(lines) do
        -- stop if we hit an start/end-of-request marker
        if vim.startswith(line, "###") then
            break
        end

        -- ignore comment lines
        if vim.startswith(line, "#") or vim.startswith(line, "//") then
            goto continue
        end

        local is_blank_line = line:match("^%s*$")

        if is_blank_line then
            -- the request body is preceded by a blank line
            if parse_stage == parse_stages.HEADERS then
                parse_stage = parse_stages.BODY
            end
            goto continue
        end

        if parse_stage == parse_stages.METHOD_URL then
            -- TODO: Support parsing multiline URLs

            -- Lua doesn't support optional capturing groups :(
            local method, url, http_version = line:match("^%s*(%u+)%s*([^%s]+)%s*(HTTP/%d%.?%d?)$")
            if method == nil or url == nil then
                method, url = line:match("^%s*(%u+)%s*([^%s]+)$")
            end

            if method == nil or url == nil then
                method = "GET"
                url = line
            end

            request.method = method
            request.url = url
            request.http_version = http_version

            parse_stage = parse_stages.HEADERS
        elseif parse_stage == parse_stages.HEADERS then
            local name, value = line:match("^%s*([%w-]+)%s*:%s*(.+)$")
            if request.headers[name] ~= nil then
                table.insert(request.headers[name], value)
            else
                request.headers[name] = { value }
            end
        elseif parse_stage == parse_stages.BODY then
            request.body = request.body .. line
        end

        ::continue::
    end

    if not request.url then
        vim.notify("Unable to parse URL of request", vim.log.levels.ERROR)
        return request
    end

    local missing_env = false

    request.url = request.url:gsub("{{(.-)}}", function(key)
        if state.env.available ~= nil and state.env.selected ~= nil then
            return state.env.available[state.env.selected][key]
        end

        missing_env = true
        return ""
    end)

    request.url = request.url

    -- "-i" => Show HTTP response headers in the output
    request.curl_cmd = { "curl", "-i" }

    if request.http_version == "HTTP/1.0" then
        table.insert(request.curl_cmd, "--http1.0")
    elseif request.http_version == "HTTP/1.1" then
        table.insert(request.curl_cmd, "--http1.1")
    elseif request.http_version == "HTTP/2" then
        table.insert(request.curl_cmd, "--http2")
    elseif request.http_version == "HTTP/3" then
        table.insert(request.curl_cmd, "--http3")
    end

    table.insert(request.curl_cmd, "-X")
    table.insert(request.curl_cmd, request.method)
    table.insert(request.curl_cmd, request.url)

    if state.cookie ~= nil then
        request.headers["Cookie"] = {}
        for cookie_name, cookie_value in pairs(state.cookie) do
            table.insert(request.headers["Cookie"], cookie_name .. "=" .. cookie_value)
        end
    end

    for header_name, header_values in pairs(request.headers) do
        for index, value in ipairs(header_values) do
            local new_value = value:gsub("{{(.-)}}", function(key)
                if state.env.available ~= nil and state.env.selected ~= nil then
                    return state.env.available[state.env.selected][key]
                end

                missing_env = true
                return ""
            end)

            request.headers[header_name][index] = new_value

            if options.shell then
                local arg = string.format("%s: %s", header_name, new_value)
                table.insert(request.curl_cmd, "-H " .. '"' .. arg .. '"')
            else
                table.insert(request.curl_cmd, "-H")
                table.insert(request.curl_cmd, string.format("%s: %s", header_name, new_value))
            end
        end
    end

    request.body = request.body:gsub("{{(.-)}}", function(key)
        if state.env.available ~= nil and state.env.selected ~= nil then
            return state.env.available[state.env.selected][key]
        end

        missing_env = true
        return ""
    end)

    if request.body ~= "" then
        if options.shell then
            table.insert(request.curl_cmd, "--data @- << EOF\n" .. request.body .. "\nEOF")
        else
            table.insert(request.curl_cmd, "--data")
            table.insert(request.curl_cmd, request.body)
        end
    end

    if missing_env then
        vim.notify("Found variables not present in the environment file.", vim.log.levels.ERROR)
        return request
    end

    request.ok = true
    return request
end

function M.change_env()
    if state.env.available == nil then
        read_env()
    end

    if state.env.available == nil then
        return
    end

    local environments = {}
    for key, _ in pairs(state.env.available) do
        table.insert(environments, key)
    end

    vim.ui.select(environments, { prompt = "Choose an environment" }, function(choice)
        if choice == nil then
            return
        end

        state.env.selected = choice
    end)
end

function M.select_from_cache()
    local choices = {}

    for url, methods in pairs(state.cache) do
        for method, _ in pairs(methods) do
            table.insert(choices, method .. " " .. url)
        end
    end

    if #choices == 0 then
        return
    end

    vim.ui.select(choices, { prompt = "Choose a request" }, function(selected_choice)
        if not selected_choice then
            return
        end

        for url, methods in pairs(state.cache) do
            for method, cached_request in pairs(methods) do
                local choice = method .. " " .. url

                if choice == selected_choice then
                    toggle_floating_window()
                    render_markdown(cached_request)
                    return
                end
            end
        end
    end)
end

function M.clear_cache()
    state.cache = {}
end

function M.clear_cookie()
    state.cookie = nil
end

function M.copy()
    read_env()

    local request = parse_request({ shell = true })

    if not request.ok then
        return
    end

    vim.fn.setreg("+", table.concat(request.curl_cmd, " \\\n"))

    vim.notify("Curl command copied to clipboard!", vim.log.levels.INFO)
end

function M.request()
    read_env()

    local request = parse_request({ shell = false })

    if not request.ok then
        return
    end

    execute_curl(request)
end

return M
