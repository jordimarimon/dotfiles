-- Be able to delete entries
vim.keymap.set("n", "dd", require("custom.quickfix").rm_qf_item, { desc = "Remove QF entry", buffer = true, silent = true })
vim.keymap.set("v", "d", require("custom.quickfix").rm_qf_items, { desc = "Remove QF entries", buffer = true, silent = true })

-- Be able to move between entries
local function move_to_next_qf()
    vim.cmd("cnext")
    vim.cmd("copen")
end

local function move_to_prev_qf()
    vim.cmd("cprev")
    vim.cmd("copen")
end

vim.keymap.set("n", "<M-j>", move_to_next_qf, { desc = "Move to next QF entry", buffer = true, silent = true })
vim.keymap.set("n", "<M-k>", move_to_prev_qf, { desc = "Move to previous QF entry", buffer = true, silent = true })

