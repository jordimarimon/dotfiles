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
vim.api.nvim_create_user_command("Messages", function()
    require("custom.command-scratch-buffer").redirect("messages")
end, { nargs = 0 })

-- Prevent default ftplugins from overriding some options
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
        local buftype = vim.bo[args.buf].buftype
        local filetype = vim.bo[args.buf].filetype

        if not vim.api.nvim_buf_is_valid(args.buf) or buftype ~= "" or filetype == "" then
            return
        end

        -- Don't insert comments when using "o" or "O"
        vim.opt.formatoptions:remove({ "o", "r" })

        -- Change how many lines scrolls C-d and C-u
        vim.o.scroll = 5
    end
})

-- Stop LSP clients when they're not attached to any buffer
vim.api.nvim_create_autocmd({ "LspDetach" }, {
    group = vim.api.nvim_create_augroup("LspStopWithLastClient", {}),
    desc = "Stop lsp client when no buffer is attached",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if not client or not client.attached_buffers then
            return
        end

        for buf_id in pairs(client.attached_buffers) do
            if buf_id ~= args.buf then
                return
            end
        end

        print('LSP client closed!')

        client:stop()
    end,
})
