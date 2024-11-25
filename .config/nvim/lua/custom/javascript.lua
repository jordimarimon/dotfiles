local M = {};

---@param  types string[] Will return the first node that matches one of these types
---@param  node  TSNode|nil
---@return TSNode|nil
function M.find_node_ancestor(types, node)
    if not node then
        return nil
    end

    if vim.tbl_contains(types, node:type()) then
        return node
    end

    local parent = node:parent()

    return M.find_node_ancestor(types, parent)
end

function M.add_async()
    vim.api.nvim_feedkeys("t", "n", true)

    local col = vim.fn.col(".")
    local text_before_cursor = vim.fn.getline("."):sub(col - 4, col - 1)

    if text_before_cursor ~= "awai" then
        return
    end

    local current_node = vim.treesitter.get_node({ ignore_injections = false })
    local function_types = { "arrow_function", "function_declaration", "function", "method_definition" }
    local function_node = M.find_node_ancestor(function_types, current_node)

    if not function_node then
        return
    end

    local function_text = vim.treesitter.get_node_text(function_node, 0)
    if vim.startswith(function_text, "async ") then
        return
    end

    local start_row, start_col = function_node:start()
    vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { "async " })
end

return M

