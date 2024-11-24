--  See `:help lua-guide-autocommands`
--  See `:help events` to see the full list of available events

-- Highlight when yanking (copying) text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- Use treesitter for folding (only if the file is not big)
vim.api.nvim_create_autocmd("BufReadPre", {
    desc = "Enable treesitter folding when the file is not too big",
    group = vim.api.nvim_create_augroup("BigFile", { clear = true }),
    callback = function(args)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))

        if ok and stats and stats.size > max_filesize then
            vim.opt.foldmethod = "manual"
        else
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
        end
    end,
})

