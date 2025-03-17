-- TODO: Look at conform implementation:
--       https://github.com/stevearc/conform.nvim
--       Look into ":help 'formatexpr'" and ":help gq"

local M = {}

--- @param files table
--- @return boolean
local function check_root(files)
    local directory = require("custom.fs").dir()
    local found = false

    while (directory and directory ~= "/") do
        for _, file in ipairs(files) do
            local path = directory .. "/" .. file
            local stat = vim.uv.fs_stat(path)

            if stat and stat.type == "file" then
                found = true
                break
            end
        end

        if found then
            break
        end

        local parent = vim.uv.fs_realpath(directory .. "/..")

        if parent == directory then
            break
        end

        directory = parent
    end

    return found
end

--- @param bufnr integer
local function prettier(bufnr)
    local buffer_path = vim.api.nvim_buf_get_name(bufnr)
    local cwd = vim.fn.getcwd()

    if vim.fn.executable("npm") == 0 then
        return
    end

    if not check_root({".prettierrc", ".prettierrc.js", "prettier.config.js"}) then
        return
    end

    local cmd = vim.system(
        { "npx", "prettier", "--write", buffer_path },
        {cwd = cwd, text = true}
    )

    cmd:wait()
end

local formatters_by_ft = {
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    html = prettier,
    css = prettier,
    json = prettier,
    markdown = prettier,
    htmlangular = prettier,
}

function M.format(bufnr)
    local ft = vim.bo[bufnr].filetype
    local formatter = formatters_by_ft[ft]

    if not formatter then
        return
    end

    formatter(bufnr)

    -- reload the buffer
    vim.bo[bufnr].autoread = true
    vim.cmd("checktime")

    print("Format done!")
end

return M
