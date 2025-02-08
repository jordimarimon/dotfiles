-- Based on: https://github.com/kwkarlwang/bufjump.nvim
-- There is also: https://github.com/wojciech-kulik/filenav.nvim

local M = {}

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

    while j > 1 and (curr_buf_num == target_buf_num or not vim.api.nvim_buf_is_valid(target_buf_num)) do
        j = j - 1
        target_buf_num = jumplist[j].bufnr
    end

    if target_buf_num ~= curr_buf_num and vim.api.nvim_buf_is_valid(target_buf_num) then
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
    while j < #jumplist and (curr_buf_num == target_buf_num or vim.api.nvim_buf_is_valid(target_buf_num) == false) do
        j = j + 1
        target_buf_num = jumplist[j].bufnr
    end

    while j + 1 <= #jumplist and jumplist[j + 1].bufnr == target_buf_num and vim.api.nvim_buf_is_valid(target_buf_num) do
        j = j + 1
    end

    if j <= #jumplist and target_buf_num ~= curr_buf_num and vim.api.nvim_buf_is_valid(target_buf_num) then
        vim.cmd([[execute "normal! ]] .. tostring(j - i) .. [[\<c-i>"]])
    end
end

return M
