vim.opt_local.spell = true
vim.opt_local.wrap = true
vim.opt_local.textwidth = 80

-- Toggle Markdown Preview
vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<CR>", {
    desc = "[M]arkdown [T]oggle",
    buffer = true,
})
