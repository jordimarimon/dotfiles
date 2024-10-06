--  See `:help lua-guide-autocommands`
--  See `:help events` to see the full list of available events

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

