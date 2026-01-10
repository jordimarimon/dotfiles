-- Other plugins:
-- https://github.com/heilgar/bookmarks.nvim/tree/main
-- https://github.com/chentoast/marks.nvim/tree/master

local M = {}
local state = {
    ns_id = vim.api.nvim_create_namespace("marks_hl_ns"),
    group = "marks_group",
    timer = nil,
}

vim.fn.sign_define("MarkSign", {
    text = "",
    texthl = "MarkSignHighlight",
    numhl = "MarkSignHighlight",
    hl_mode = "combine",
})

---@param char string
local function is_upper(char)
    return (65 <= char:byte() and char:byte() <= 90)
end

---@param char string
local function is_lower(char)
    return (97 <= char:byte() and char:byte() <= 122)
end

---@param buffer integer
---@param data vim.fn.getmarklist.ret.item
local function set_mark(buffer, data)
    local line = data.pos[2]
    local mark_name = data.mark

    vim.fn.sign_place(0, state.group, "MarkSign", buffer, { lnum = line, priority = 10 })

    vim.api.nvim_buf_set_extmark(buffer, state.ns_id, line - 1, 0, {
        virt_text = {
            { mark_name, "MarkHighlight" },
        },
        virt_text_pos = "eol_right_align",
        priority = 10,
    })

    -- vim.hl.range(buffer, state.ns_id, "MarkHighlight", { line, 0 }, { line - 1, -1 })
end

--- @param bufnr integer
function M.remove(bufnr)
    local buffer = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end

    local buftype = vim.bo[buffer].buftype
    local filetype = vim.bo[buffer].filetype
    if buftype ~= "" or filetype == "" then
        return
    end

    vim.fn.sign_unplace(state.group, { buffer = bufnr })
    vim.api.nvim_buf_clear_namespace(bufnr, state.ns_id, 0, -1)
end

--- @param bufnr integer?
function M.update(bufnr)
    local buffer = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end

    local buftype = vim.bo[buffer].buftype
    local filetype = vim.bo[buffer].filetype
    if buftype ~= "" or filetype == "" then
        return
    end

    if state.timer == nil then
        state.timer = vim.loop.new_timer()
        state.timer:start(500, 250, vim.schedule_wrap(M.update))
    end

    M.remove(buffer)

    -- When we ask for the marklist, we only get the uppercase
    -- marks when we don't specify the buffer.

    -- uppercase
    local global_marks = vim.fn.getmarklist()
    for _, data in ipairs(global_marks) do
        local mark_char = data.mark:sub(2, 3)
        local mark_buf = data.pos[1]

        if mark_buf == buffer and is_upper(mark_char) then
            set_mark(buffer, data)
        end
    end

    -- lowercase
    local local_marks = vim.fn.getmarklist(buffer)
    for _, data in ipairs(local_marks) do
        local mark_char = data.mark:sub(2, 3)

        if is_lower(mark_char) then
            set_mark(buffer, data)
        end
    end
end

return M
