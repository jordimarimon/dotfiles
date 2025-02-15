local M = {}

function M.remove()
    local MiniIndentScope = require("mini.indentscope")
    local scope = MiniIndentScope.get_scope()
    local top = scope.border.top
    local bottom = scope.border.bottom
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

    vim.cmd(string.format("%s,%snorm <<", top, bottom))
    vim.cmd(string.format("norm %sGdd", top))
    vim.cmd(string.format("norm %sGdd", bottom - 1))

    if row == top then
        vim.cmd(string.format("norm %sG", row))
    else
        vim.cmd(string.format("norm %sG", row - 1))
    end
end

return M
