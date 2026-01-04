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
---@field body string[]
---@field curl_cmd string[]

---@class Response
---@field status integer
---@field headers table
---@field body string[]

---@class CachedRequest
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

local function read_env()
    if state.env.available ~= nil then
        return
    end

    local env_file_name = "http-client.env.json"
    local env_dir = fs.root_files({ env_file_name })

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

    local READ_ONLY = 00444 -- `:Man 2 open`
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

---@param value string
---@return string[]
local function format_json(value)
    local job = vim.system({ "jq", "." }, { text = true, stdin = value })
    local result = job:wait()

    if result.code ~= 0 then
        return String.split(value, "\n")
    end

    return String.split(result.stdout, "\n")
end

---@param mime_type string
---@param value string
---@return string[]
local function format_value(mime_type, value)
    if mime_type == "application/json" then
        return format_json(value)
    end

    vim.notify("Format not supported " .. mime_type, vim.log.levels.WARN)

    return String.split(value, "\n")
end

---@param mime_type string
---@return string
local function get_code_block_type(mime_type)
    if mime_type == "application/json" then
        return "json"
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

---@param cached_request CachedRequest
local function render_markdown(cached_request)
    local output = {}
    local request, response = cached_request.request, cached_request.response
    local req_body_mime_type = request.headers["Content-Type"] or ""
    local res_body_mime_type = response.headers["Content-Type"] or ""

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
        vim.list_extend(output, format_value(req_body_mime_type, table.concat(request.body, "\n")))
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
    vim.list_extend(output, format_value(res_body_mime_type, table.concat(response.body, "\n")))
    table.insert(output, "```")

    vim.api.nvim_buf_set_lines(state.buffer_id, 0, -1, false, output)
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

    local header_str, body_str = response.stdout:match("^(.-)\n\n(.*)$")

    local status = -1
    local headers = {}
    local header_lines = header_str:gmatch("[^\n]+")
    for line in header_lines do
        if vim.startswith(line, "HTTP") then
            status = math.floor(line:match("HTTP/%d+%.%d+ (%d+)"))
            goto continue
        end

        local key, value = line:match("^(.-):%s*(.*)$")
        if key and value then
            headers[key] = value
        end

        ::continue::
    end

    if headers["Set-Cookie"] then
        state.cookie = String.split(headers["Set-Cookie"], ";")[1]
    end

    ---@type CachedRequest
    local cached_request = {
        request = request,
        response = {
            status = status,
            headers = headers,
            body = String.split(tostring(body_str), "\n"),
        },
    }

    state.cache[request.url] = state.cache[request.url] or {}
    state.cache[request.url][request.method] = cached_request

    toggle_floating_window()

    render_markdown(cached_request)

    vim.notify("Response parsed!", vim.log.levels.INFO)
end

---@param request Request
local function execute_curl(request)
    if vim.fn.executable("curl") == 0 then
        vim.notify("Can't find curl executable.", vim.log.levels.ERROR)
        return
    end

    vim.notify("Making HTTP request...", vim.log.levels.INFO)

    vim.system(request.curl_cmd, { text = true }, function(response)
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
        headers = {},
        body = {},
        curl_cmd = {},
    }

    local ft = vim.bo.filetype
    if ft ~= "http" then
        vim.notify("Expected the HTTP request to be in an http filetype", vim.log.levels.ERROR)
        return request
    end

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

        local is_blank_line = line:match("^%s*$")

        if is_blank_line then
            -- the request body is preceded by a blank line
            if parse_stage == parse_stages.HEADERS then
                parse_stage = parse_stages.BODY
            end
            goto continue
        end

        if parse_stage == parse_stages.METHOD_URL then
            local method, url = line:match("^%s*(%u+)%s*(.+)$")
            request.method = method
            request.url = url

            if method == nil or url == nil then
                request.method = "GET"
                request.url = line
            end

            parse_stage = parse_stages.HEADERS
        elseif parse_stage == parse_stages.HEADERS then
            local name, value = line:match("^%s*([%w-]+)%s*:%s*(.+)$")
            request.headers[name] = value
        elseif parse_stage == parse_stages.BODY then
            table.insert(request.body, line)
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

    request.curl_cmd = { "curl", "-i", "-X", request.method, request.url }

    if state.cookie ~= nil then
        request.headers["Cookie"] = state.cookie
    end

    for header_name, header_value in pairs(request.headers) do
        local value = header_value:gsub("{{(.-)}}", function(key)
            if state.env.available ~= nil and state.env.selected ~= nil then
                return state.env.available[state.env.selected][key]
            end

            missing_env = true
            return ""
        end)

        request.headers[header_name] = value

        if options.shell then
            table.insert(
                request.curl_cmd,
                "-H " .. '"' .. string.format("%s: %s", header_name, value) .. '"'
            )
        else
            table.insert(request.curl_cmd, "-H")
            table.insert(request.curl_cmd, string.format("%s: %s", header_name, value))
        end
    end

    if #request.body ~= 0 then
        local new_body_lines = {}

        for _, body_line in ipairs(request.body) do
            local new_body_line = body_line:gsub("{{(.-)}}", function(key)
                if state.env.available ~= nil and state.env.selected ~= nil then
                    return state.env.available[state.env.selected][key]
                end

                missing_env = true
                return ""
            end)

            table.insert(new_body_lines, new_body_line)
        end

        request.body = new_body_lines

        if options.shell then
            table.insert(
                request.curl_cmd,
                "--data @- << EOF\n" .. table.concat(new_body_lines, "\n") .. "\nEOF"
            )
        else
            table.insert(request.curl_cmd, "--data")
            table.insert(request.curl_cmd, table.concat(new_body_lines, "\n"))
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
