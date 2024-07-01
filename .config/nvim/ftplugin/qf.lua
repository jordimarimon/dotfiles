-- Be able to delete entries
vim.keymap.set("n", "dd", require("custom.quickfix").rm_qf_item, { desc = "Remove QF entry", buffer = true, silent = true })

