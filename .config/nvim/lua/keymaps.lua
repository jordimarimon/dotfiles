local todo_comments = require("todo-comments")

-- Remove any keymap set in the leader key
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Clear higlight search on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Keybinds to make split navigation easier.
-- See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window", silent = true })

-- Keybinds to move in insert mode
vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", { desc = "Move to the left", silent = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", { desc = "Move to the right", silent = true })
vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", { desc = "Move down", silent = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", { desc = "Move up", silent = true })

-- Todo comments keymaps
vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "[S]earch [T]odos", silent = true })
vim.keymap.set("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment", silent = true })
vim.keymap.set("n", "[t", function() todo_comments.jump_prev() end, { desc = "Previous todo comment", silent = true })

-- Copy current buffer path to system clipboard
vim.keymap.set("n", "<leader>cf", function() vim.fn.setreg("+", vim.fn.expand('%')) end, { desc = "[C]opy [F]ile path", silent = true })

-- To move between tabs
vim.api.nvim_set_keymap("n", "<M-h>", ":tabp<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-l>", ":tabn<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-S-h>", ":-tabmove<CR>", { silent = true, noremap = true, desc = "[T]ab [M]ove [P]revious" })
vim.api.nvim_set_keymap("n", "<M-S-l>", ":+tabmove<CR>", { silent = true, noremap = true, desc  = "[T]ab [M]ove [N]ext" })

-- Reload the current file and delete other buffers
vim.keymap.set("n", "<leader>rb", "<cmd>%bd|e#|bd#<CR>", { desc = "[R]eload [B]uffer", silent = true })

-- I have the bad habit of not releasing the shift key when saving
vim.api.nvim_create_user_command('Wa', 'wa', { desc = "Write all" })
vim.api.nvim_create_user_command('Wq', 'wq', { desc = "Write and quit" })

