-- Based on: https://github.com/vuki656/package-info.nvim

local fidget = require("fidget.notification")

local M = {}
local state = {
    is_visible = false,
    is_pending = false,
    notification = {
        key = "NpmOutdated",
        group = "NpmOutdated",
    },
    augroup = vim.api.nvim_create_augroup("NpmOutdated", { clear = true }),
    namespace = {
        id = vim.api.nvim_create_namespace("npm-outdated"),
    },
    buffer = {
        id = -1,
        lines = {},
    },
    dependencies = {
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
            outdated = {},
        }
    end,
})

--- @param msg string
local log_error = function(msg)
    fidget.notify(msg, vim.log.levels.ERROR, {
        group = state.notification.group,
        key = state.notification.key,
        ttl = 10,
    })
end

--- @param msg string
local log_info = function(msg, ttl)
    fidget.notify(msg, vim.log.levels.INFO, {
        group = state.notification.group,
        key = state.notification.key,
        ttl = ttl,
    })
end

local reload_buffer = function()
    vim.bo[state.buffer.id].autoread = true
    vim.cmd("checktime")
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

    log_info("Updated package.json!", 5)
end

local on_error = function()
    state.is_pending = false
end

local on_exit = function (obj)
    local ok, json_value = pcall(vim.json.decode, obj.stdout)

    if not ok then
        log_error("Error while parsing command output")
        on_error()
        return
    end

    state.dependencies.outdated = json_value
    on_success()
end

local display_outdated_dependencies = function()
    -- If we have them already, we don't need to compute them again
    if next(state.dependencies.outdated) ~= nil then
        on_success()
        return
    end

    if vim.fn.executable("npm") == 0 then
        log_error("NPM command not found")
        on_error()
        return
    end

    -- Don't check the exit code because the command
    -- always returns "1"
    vim.system({"npm", "outdated", "--json"}, {text = true}, function (obj)
        vim.schedule(function() on_exit(obj) end)
    end)
end

local show = function()
    -- Reload buffer before reading it
    reload_buffer()

    -- Read the buffer content
    state.buffer.lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    --Run "npm outdated" command
    display_outdated_dependencies()
end

local hide = function()
    -- Clear virtual text
    clear()

    -- Reload buffer after removing the virtual text
    reload_buffer()

    state.is_visible = false
    state.is_pending = false

    log_info("Updated package.json!", 5)
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

    log_info("Updating package.json...", 120)

    state.is_pending = true
    state.buffer.id = vim.fn.bufnr()

    if state.is_visible then
        hide()
    else
        show()
    end
end

return M
