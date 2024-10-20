local todo_comments = require("todo-comments")

-- Remove any keymap set in the leader key
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Clear higlight search on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Keybinds to make split navigation easier.
-- See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Todo comments keymaps
vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "[S]earch [T]odos" })
vim.keymap.set("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment" })
vim.keymap.set("n", "[t", function() todo_comments.jump_prev() end, { desc = "Previous todo comment" })

-- Copy current buffer path to system clipboard
vim.keymap.set("n", "<leader>cf", function() vim.fn.setreg("+", vim.fn.expand('%')) end, { desc = "[C]opy [F]ile path" })

-- To move between tabs
vim.api.nvim_set_keymap("n", "<M-h>", ":tabp<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-l>", ":tabn<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-S-h>", ":-tabmove<CR>", { silent = true, noremap = true, desc = "[T]ab [M]ove [P]revious" })
vim.api.nvim_set_keymap("n", "<M-S-l>", ":+tabmove<CR>", { silent = true, noremap = true, desc  = "[T]ab [M]ove [N]ext" })

