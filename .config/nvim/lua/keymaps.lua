-- Remove any keymap set in the leader key
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Clear higlight search on pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", function()
    return vim.v.count > 0 and "m'" .. vim.v.count .. "k" or "gk"
end, { expr = true, silent = true })

vim.keymap.set("n", "j", function()
    return vim.v.count > 0 and "m'" .. vim.v.count .. "j" or "gj"
end, { expr = true, silent = true })

-- Move up and down only 5 lines. Sadly the "scroll" option
-- gets overriden in a lot of places
vim.keymap.set({ "n", "v" }, "<C-u>", "5k", { silent = true })
vim.keymap.set({ "n", "v" }, "<C-d>", "5j", { silent = true })

-- Center cursor when moving up or down
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zz", { silent = true })
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zz", { silent = true })

-- Useful keympas for deleting and pasting
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Deletes to black hole register", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>x", "\"_x", { desc = "Deletes to black hole register", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>c", "\"_c", { desc = "Changes to black hole register", silent = true })
vim.keymap.set({ "n", "v" }, "<leader>p", "\"0p", { desc = "Pastes from yank buffer", silent = true })

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

-- To move between tabs
vim.api.nvim_set_keymap("n", "<M-h>", ":tabp<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-l>", ":tabn<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<M-S-h>", ":-tabmove<CR>",
    { silent = true, noremap = true, desc = "[T]ab [M]ove [P]revious" })
vim.api.nvim_set_keymap("n", "<M-S-l>", ":+tabmove<CR>", { silent = true, noremap = true, desc = "[T]ab [M]ove [N]ext" })

-- I have the bad habit of not releasing the shift key when saving
vim.api.nvim_create_user_command('Wa', 'wa', { desc = "Write all" })
vim.api.nvim_create_user_command('Wq', 'wq', { desc = "Write and quit" })

-- For resolving conflicts when rebasing or mering
vim.keymap.set({ "n", "v" }, "<leader>gh", "<cmd>diffget //2<CR>")
vim.keymap.set({ "n", "v" }, "<leader>gl", "<cmd>diffget //3<CR>")

-- Stay in visual mode after indenting visual selection
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Keep current search result centered on the screen
vim.keymap.set("n", "n", ":keepjumps normal! nzz<CR>", { noremap = true })
vim.keymap.set("n", "N", ":keepjumps normal! Nzz<CR>", { noremap = true })

-- Keep current cursor position while entering and exiting insert mode
vim.keymap.set("i", "<Esc>", function()
    return vim.fn.pumvisible() == 1 and "<Esc>i<Right>" or "<Right><Esc>"
end, { noremap = true, expr = true })

-- Open current file directory
vim.keymap.set("n", "-", "<cmd>Oil<CR>")

-- Search inside a visual selection
vim.keymap.set("x", "g/", "<Esc>/\\%V")

-- Jumps between buffers in the jumplist
vim.keymap.set("n", "<M-o>", function()
    require("custom.buffer-jumps").backward()
end, { noremap = true, silent = true, desc = "Jump to previous buffer" })

vim.keymap.set("n", "<M-i>", function()
    require("custom.buffer-jumps").foward()
end, { noremap = true, silent = true, desc = "Jump to next buffer" })

-- Remove outer scope
vim.keymap.set("n", "<leader>do", function()
    require("custom.delete-outer-scope").remove()
end, { noremap = true, silent = true, desc = "[D]elete [O]uter scope" })

-- List all loaded buffers and populates the prompt for changing to a specific buffer
vim.keymap.set("n", "gb", ":ls<CR>:b<Space>", { noremap = true, silent = true, desc = "Search in loaded buffers" })

-- Save current word for later substitute command
vim.keymap.set({ "n", "v" }, "<leader>s", function()
    local mode = vim.fn.mode()
    -- Check if in visual mode
    if mode == "v" then
        -- Get the selected text in visual mode
        local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
        -- Set the search register to the selection
        vim.fn.setreg('/', table.concat(selection, "\n"))
    elseif mode == "n" then
        -- Get the word under the cursor
        local word = vim.fn.expand("<cword>")
        -- Set the search register to the word
        vim.fn.setreg("/", word)
    end

    print("Search saved!")
end, { desc = "[S]ave [S]earch" })

vim.keymap.set("n", "[m", function ()
    require("custom.treesitter").go_to_start_function()
end, { noremap = true, silent = true, desc = "Go to the start of the function/method" })
