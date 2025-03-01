-- Be able to delete entries
vim.keymap.set("n", "dd", require("custom.quickfix").rm_qf_item, { desc = "Remove entry", buffer = true, silent = true })
vim.keymap.set("x", "d", require("custom.quickfix").rm_qf_items, { desc = "Remove entries", buffer = true, silent = true })

vim.keymap.set("n", "<M-j>", require("custom.quickfix").move_to_next, { desc = "Move to next entry", buffer = true, silent = true })
vim.keymap.set("n", "<M-k>", require("custom.quickfix").move_to_prev, { desc = "Move to previous entry", buffer = true, silent = true })

-- Open diff of an entry
vim.keymap.set("n", "o", function ()
    require("custom.git-difftool").diff()
end, { buffer = true, silent = true, desc = "[O]pen diff vertically" })

