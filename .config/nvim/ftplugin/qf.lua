-- Be able to delete entries
vim.keymap.set("n", "dd", require("custom.quickfix").rm_qf_item, { desc = "Remove QF entry", buffer = true, silent = true })
vim.keymap.set("v", "d", require("custom.quickfix").rm_qf_items, { desc = "Remove QF entries", buffer = true, silent = true })

