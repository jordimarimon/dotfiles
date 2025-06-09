local M = {}

---@param  types string[] Will return the first node that matches one of these types
---@param  node  TSNode|nil
---@return TSNode|nil
function M.find_node_ancestor(types, node)
    local current_node = node ---@type TSNode|nil

    while true do
        if not current_node then
            break
        end

        if vim.tbl_contains(types, current_node:type()) then
            break
        end

        current_node = current_node:parent()
    end

    return current_node
end

function M.go_to_start_function()
    local node = vim.treesitter.get_node()
    local function_types = {
        "arrow_function",
        "function_declaration",
        "function",
        "function_definition",
        "method_definition",
    }

    local function_node = M.find_node_ancestor(function_types, node)
    if not function_node then
        return
    end

    -- So we can add the current cursor position to the jump list
    vim.cmd("normal! m'")

    local start_row, start_col = function_node:start()
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
end

return M
