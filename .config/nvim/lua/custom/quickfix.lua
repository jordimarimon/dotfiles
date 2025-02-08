local M = {}

-- Quickfix list delete item
function M.rm_qf_item()
    local curqfidx = vim.fn.line(".")
    local qfall = vim.fn.getqflist()

    -- Return if there are no items to remove
    if #qfall == 0 then
      return
    end

    -- Remove the item from the quickfix list
    table.remove(qfall, curqfidx)
    vim.fn.setqflist(qfall, "r")

    -- Reopen quickfix window to refresh the list
    vim.cmd("copen")

    -- If not at the end of the list, stay at the same index, otherwise, go one up.
    local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

    -- Set the cursor position directly in the quickfix window
    local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
    vim.api.nvim_win_set_cursor(winid, {new_idx, 0})
end

-- Quickfix list delete multiple items
function M.rm_qf_items()
    local startidx = vim.fn.line("v")
    local endidx = vim.fn.line(".")
    local qfall = vim.fn.getqflist()

    -- Return if there are no items to remove
    if #qfall == 0 then
      return
    end

    -- Ensure the indices are within the valid range
    if startidx < 1 or endidx > #qfall or startidx > endidx then
        return
    end

    -- Remove the items from the list
    for i = endidx, startidx, -1 do
        table.remove(qfall, i)
    end

    vim.fn.setqflist(qfall, "r")

    -- Reopen quickfix window to refresh the list
    vim.cmd("copen")

    -- Set the cursor position directly in the quickfix window
    local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
    vim.api.nvim_win_set_cursor(winid, {startidx, 0})
end

return M
