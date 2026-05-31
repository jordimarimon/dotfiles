-- Based on: https://github.com/kwkarlwang/bufjump.nvim
-- There is also: https://github.com/wojciech-kulik/filenav.nvim

local M = {}

--- Helper function to check if a buffer is a valid jump target
--- @param bufnr number
--- @return boolean
local function is_valid_target(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

    -- If it's a standard file (empty buftype) and has a file path
    --    we verify the file actually still exists on the system.
    --    We ignore special buffers like terminals, help files, or oil:// buffers.
    if buftype == "" and bufname ~= "" then
        if vim.fn.filereadable(bufname) == 0 then
            return false
        end
    end

    return true
end

function M.backward()
    local getjumplist = vim.fn.getjumplist()
    local jumplist = getjumplist[1]
    local last_jump_pos = getjumplist[2]

    if #jumplist == 0 then
        return
    end

    -- plus one because of one index
    local i = last_jump_pos + 1
    local j = i
    local curr_buf_num = vim.fn.bufnr()
    local target_buf_num = curr_buf_num

    while j > 1 and (curr_buf_num == target_buf_num or not is_valid_target(target_buf_num)) do
        j = j - 1
        target_buf_num = jumplist[j].bufnr
    end

    if target_buf_num ~= curr_buf_num and is_valid_target(target_buf_num) then
        vim.cmd([[execute "normal! ]] .. tostring(i - j) .. [[\<c-o>"]])
    end
end

function M.foward()
    local getjumplist = vim.fn.getjumplist()
    local jumplist = getjumplist[1]
    local last_jump_pos = getjumplist[2]

    if #jumplist == 0 then
        return
    end

    local i = last_jump_pos + 1
    local j = i
    local curr_buf_num = vim.fn.bufnr()
    local target_buf_num = curr_buf_num

    -- find the next different buffer
    while
        j < #jumplist
        and (curr_buf_num == target_buf_num or not is_valid_target(target_buf_num))
    do
        j = j + 1
        target_buf_num = jumplist[j].bufnr
    end

    while
        j + 1 <= #jumplist
        and jumplist[j + 1].bufnr == target_buf_num
        and is_valid_target(target_buf_num)
    do
        j = j + 1
    end

    if j <= #jumplist and target_buf_num ~= curr_buf_num and is_valid_target(target_buf_num) then
        vim.cmd([[execute "normal! ]] .. tostring(j - i) .. [[\<c-i>"]])
    end
end

return M
