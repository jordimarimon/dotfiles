local M = {}
local ns = vim.api.nvim_create_namespace("qflist")

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
    vim.api.nvim_win_set_cursor(winid, { new_idx, 0 })
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
    vim.api.nvim_win_set_cursor(winid, { startidx, 0 })
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

-- :help quickfix-window-function
--- @class QuickFixInfo
--- @field quickfix integer
--- @field winid integer
--- @field id integer
--- @field start_idx integer
--- @field end_idx integer

---@param info QuickFixInfo
function M.entries_text(info)
    -- Get the quickfix list or location list.
    -- We also specify what information we want to retrieve
    local list = {}
    local query = { id = info.id, items = 1, qfbufnr = 1 }
    local entries = {}

    if info.quickfix == 1 then
        list = vim.fn.getqflist(query)
    else
        list = vim.fn.getloclist(info.winid, query)
    end

    local is_git = false

    -- Create each entry with the highlights
    for _, item in ipairs(list.items) do
        local entry = { { "  ", "qfText" } }
        local fname = vim.fn.bufname(item.bufnr)
        fname = vim.fn.fnamemodify(fname, ":p:.")

        if fname:find("^fugitive://") then
            is_git = true
            break
        end

        local text = item.text:match("^%s*(.-)%s*$") -- trim item.text

        table.insert(entry, { fname, "qfFilename" })
        table.insert(entry, { ":", "qfText" })
        table.insert(entry, { item.lnum, "qfLineNr" })
        table.insert(entry, { ": ", "qfText" })
        table.insert(entry, { text, "qfText" })
        table.insert(entries, entry)
    end

    if is_git then
        return {}
    end

    -- Apply highlights
    vim.schedule(function()
        for i, entry in ipairs(entries) do
            local col = 0
            for _, text in ipairs(entry) do
                vim.hl.range(list.qfbufnr, ns, text[2], { i - 1, col }, { i - 1, col + #tostring(text[1]) })
                col = col + #tostring(text[1])
            end
        end
    end)

    -- Concatenate text of each entry
    local lines = {}

    for _, entry in ipairs(entries) do
        local line = ""

        for _, text in ipairs(entry) do
            line = line .. text[1]
        end

        table.insert(lines, line)
    end

    return lines
end

return M
