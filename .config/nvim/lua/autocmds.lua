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

-- https://neovim.io/doc/user/diff.html#%3ADiffOrig
vim.api.nvim_create_user_command("DiffOrig", function()
    -- Get the current buffer's name
    local buff_name = vim.api.nvim_buf_get_name(0)
    local ft = vim.bo.filetype

    -- Check if the current buffer has a name (i.e., it's not an unnamed buffer)
    if buff_name == "" then
        print("Current buffer has no name.")
        return
    end

    -- Start diff mode on the current buffer
    vim.cmd("diffthis")

    -- Open a new vertical split
    vim.cmd("vnew")

    -- Set the buffer type to "nofile"
    vim.bo.buftype = "nofile"
    vim.bo.filetype = ft

    -- Read the current buffer into the new buffer
    vim.cmd("read " .. buff_name)

    -- Delete the first line (0d_)
    vim.cmd("0d_")

    -- Start diff mode on the current buffer
    vim.cmd("diffthis")
end, {})

-- Open the git remote repository in the browser
vim.api.nvim_create_user_command("GitRepo", function(opts)
    local git = require("custom.git-browse")
    git.update_priority(opts.bang)
    git.open_repo()
end, { range = true, bang = true, nargs = "*" })

-- Open the current file in the git remote repository in the browser
vim.api.nvim_create_user_command("GitFile", function(opts)
    local git = require("custom.git-browse")
    git.update_priority(opts.bang)
    git.open_repo_file(opts.line1, opts.line2)
end, { range = true, bang = true, nargs = "*" })

-- Highlight current line on active window only
local active_line_highligh = vim.api.nvim_create_augroup("HighlightActiveLine", { clear = true })
vim.api.nvim_create_autocmd("WinEnter", {
    desc = "show cursorline",
    callback = function() vim.wo.cursorline = true end,
    group = active_line_highligh
})
vim.api.nvim_create_autocmd("WinLeave", {
    desc = "hide cursorline",
    callback = function() vim.wo.cursorline = false end,
    group = active_line_highligh
})

-- Use vertical splits for help windows
local vertical_help = vim.api.nvim_create_augroup("VerticalHelp", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    desc = "make help split vertical",
    pattern = "help",
    command = "wincmd L",
    group = vertical_help
})

-- Open `:messages` command in a buffer
vim.api.nvim_create_user_command("Messages", function ()
    require("custom.command-scratch-buffer").redirect("messages")
end, { nargs = 0 })

-- Prevent default ftplugins to insert comments when using "o" or "O"
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions:remove({ "o", "r" })
    end
})
