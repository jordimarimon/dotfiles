local M = {}

-- There is also "vim.api.nvim_buf_get_name(0)" but it doesn't
-- follow symlinks and it includes the file name
--- @return string|nil
function M.dir()
    -- ":h ::h" and ":h ::p"
    local path = vim.fn.expand("%:p:h")

    if vim.startswith(path, "oil://") then
        path = string.sub(path, 7)
    end

    return vim.uv.fs_realpath(path)
end

--- @param files table
--- @return string?
function M.root_files(files)
    return vim.fs.root(0, files);
end

return M
