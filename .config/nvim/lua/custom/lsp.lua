local M = {}

---@param bufnr integer
---@param on_dir fun(root_dir?:string)
---@param root_markers string[]
function M.root_dir(bufnr, on_dir, root_markers)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    local buftype = vim.bo[bufnr].buftype
    local filetype = vim.bo[bufnr].filetype
    if buftype ~= "" or filetype == "" then
        return
    end

    local bufname = vim.fn.bufname(bufnr)
    if bufname:find("fugitive://", 1, true) == 1 then
        return
    end

    local root_dir = vim.fs.root(0, root_markers)

    if not root_dir then
        return
    end

    on_dir(root_dir)
end

return M
