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

function M.get_list_type()
    local all_windows = vim.fn.getwininfo()
    local is_qf = true

    for _, window in ipairs(all_windows) do
        if window.loclist == 1 then
            is_qf = false
            break
        end
    end

    return is_qf and "quickfix" or "location"
end

function M.move_to_next()
    local list_type = M.get_list_type()
    local next_command = list_type == "quickfix" and "cnext" or "lnext"
    local first_command = list_type == "quickfix" and "cfirst" or "lfirst"
    local open_command = list_type == "quickfix" and "copen" or "lopen"

    local success = pcall(function() vim.cmd(next_command) end)

    if not success then
        vim.cmd(first_command)
    end

    vim.cmd(open_command)
end

function M.move_to_prev()
    local list_type = M.get_list_type()
    local prev_command = list_type == "quickfix" and "cprev" or "lprev"
    local last_command = list_type == "quickfix" and "clast" or "llast"
    local open_command = list_type == "quickfix" and "copen" or "lopen"

    local success = pcall(function() vim.cmd(prev_command) end)

    if not success then
        vim.cmd(last_command)
    end

    vim.cmd(open_command)
end

return M
