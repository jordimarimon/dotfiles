local M = {}

local state = {
    is_visible = false,
    is_pending = false,
    augroup = vim.api.nvim_create_augroup("NpmOutdated", { clear = true }),
    namespace = {
        id = vim.api.nvim_create_namespace("npm-outdated"),
    },
    buffer = {
        id = -1,
        lines = {},
    },
    dependencies = {
        runtime = {},
        dev = {},
        peer = {},
        optional = {},
        outdated = {},
    },
}

vim.api.nvim_create_autocmd("BufDelete", {
    group = state.augroup,
    callback = function(args)
        if args.buf ~= state.buffer.id then
            return
        end

        state.is_visible = false
        state.is_pending = false
        state.buffer.id = -1
        state.buffer.lines = {}
        state.dependencies = {
            runtime = {},
            dev = {},
            peer = {},
            optional = {},
            outdated = {},
        }
    end,
})

--- @param msg string
local log_error = function(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

--- @param msg string
local log_info = function(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

local reload_buffer = function()
    vim.bo[state.buffer.id].autoread = true
    vim.cmd(":checktime")
end

--- Strips ^ and ~ from version
---
--- @param value string Value from which to strip ^ and ~ from
--- @return string?
local clean_version = function(value)
    if value == nil then
        return nil
    end

    ---@diagnostic disable-next-line: redundant-return-value
    return value:gsub("%^", ""):gsub("~", "")
end

--- @param json table
local get_current_version = function(json)
    local result = {}
    for name, version in pairs(json) do
        result[name] = {
            current = clean_version(version),
        }
    end
    return result
end

local parse_buffer = function()
    local buffer_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buffer_json_value = vim.json.decode(table.concat(buffer_lines))

    state.buffer.lines = buffer_lines
    state.dependencies.runtime = get_current_version(buffer_json_value["dependencies"] or {})
    state.dependencies.dev = get_current_version(buffer_json_value["devDependencies"] or {})
    state.dependencies.optional = get_current_version(buffer_json_value["optionalDependencies"] or {})
    state.dependencies.peer = get_current_version(buffer_json_value["peerDependencies"] or {})
end

local clear = function()
    vim.api.nvim_buf_clear_namespace(state.buffer.id, state.namespace.id, 0, -1)
end

local display = function()
    local is_dependencies = false
    local markers = {
        "dependencies",
        "peerDependencies",
        "devDependencies",
        "optionalDependencies",
    }

    for line_number, line_content in ipairs(state.buffer.lines) do
        if string.find(line_content, "}") ~= nil then
            is_dependencies = false
            goto continue
        end

        if is_dependencies then
            local name = string.match(line_content, [["([^"]+)"%s*:]])

            if name ~= nil then
                local dependency = state.dependencies.outdated[name]

                if dependency ~= nil then
                    local wanted_version = dependency.wanted
                    local latest_version = dependency.latest

                    local info_text = " " .. wanted_version
                    local separator_text = ""
                    local warning_text = ""

                    if wanted_version ~= latest_version then
                        separator_text = " | "
                        warning_text = " " .. latest_version
                    end

                    vim.api.nvim_buf_set_extmark(state.buffer.id, state.namespace.id, line_number - 1, 0, {
                        virt_text = {
                            { info_text, "DiagnosticInfo" },
                            { separator_text, "Normal" },
                            { warning_text, "DiagnosticWarn" },
                        },
                        virt_text_pos = "eol",
                        priority = 200,
                    })
                end
            end
        else
            for _, marker in ipairs(markers) do
                if string.find(line_content, marker) ~= nil then
                    is_dependencies = true
                    goto continue
                end
            end
        end

        ::continue::
    end
end

local on_success = function()
    local is_loaded = vim.api.nvim_buf_is_loaded(state.buffer.id)

    if not is_loaded then
        state.is_pending = false
        log_error("Buffer with package.json is not loaded")
        return
    end

    --Show virtual text
    display()

    -- Reload buffer after writting the virtual text
    reload_buffer()

    state.is_visible = true
    state.is_pending = false

    log_info("Updated package.json!")
end

local on_error = function()
    state.is_pending = false
end

local get_outdated_dependencies = function()
    if next(state.dependencies.outdated) ~= nil then
        on_success()
        return
    end

    local value = ""

    if vim.fn.executable("npm") == 0 then
        log_error("NPM command not found")
        on_error()
        return
    end

    -- Don't check the exit code because the command
    -- always returns "1"
    vim.fn.jobstart("npm outdated --json", {
        cwd = vim.fn.getcwd(),
        on_exit = function()
            local ok, json_value = pcall(vim.json.decode, value)

            if not ok then
                log_error("Error while parsing command output")
                on_error()
                return
            end

            state.dependencies.outdated = json_value
            on_success()
        end,
        on_stdout = function(_, stdout)
            value = value .. table.concat(stdout)
        end,
    })
end

local show = function()
    if next(state.buffer.lines) == nil then
        -- Reload buffer before reading it
        reload_buffer()

        -- Parse buffer as JSON
        parse_buffer();
    end

    --Run "npm outdated" command
    get_outdated_dependencies()
end

local hide = function()
    -- Clear virtual text
    clear()

    -- Reload buffer after removing the virtual text
    reload_buffer()

    state.is_visible = false
    state.is_pending = false

    log_info("Updated package.json!")
end

function M.toggle()
    if state.is_pending then
        return
    end

    -- Get the path of the opened file if there is one
    local file_path = vim.fn.expand("%:p")

    -- If the file is not a package.json, don't do anything
    if string.sub(file_path, -12) ~= "package.json" then
        log_error("Current buffer is not a package.json")
        return
    end

    log_info("Updating package.json....")

    state.is_pending = true
    state.buffer.id = vim.fn.bufnr()

    if state.is_visible then
        hide()
    else
        show()
    end
end

return M
