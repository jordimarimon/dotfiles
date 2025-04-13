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

-- Yank-Ring
local prev_reg0_content = vim.fn.getreg("0")
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Make yank work as delete and use the registers 1-9",
    group = vim.api.nvim_create_augroup("YankRing", { clear = true }),
    callback = function()
        if vim.v.event.operator == "y" then
            for i = 9, 2, -1 do
                vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
            end
            vim.fn.setreg("1", prev_reg0_content)
            prev_reg0_content = vim.fn.getreg("0")
        end
    end,
})

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

-- Marks
-- Refresh on file write
-- Refresh on buffer enter/read
-- Clean up on buffer delete
local group = vim.api.nvim_create_augroup("MarksAutocmds", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        vim.defer_fn(function()
            require("custom.marks").update(args.buf)
        end, 200)
    end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead" }, {
    group = group,
    callback = function(args)
        vim.defer_fn(function()
            require("custom.marks").update(args.buf)
        end, 200)
    end,
})
vim.api.nvim_create_autocmd({ "BufDelete" }, {
    group = group,
    callback = function(args)
        require("custom.marks").remove(args.buf)
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

-- Open `:messages` command in a buffer
vim.api.nvim_create_user_command("Messages", function()
    require("custom.command-scratch-buffer").redirect("messages")
end, { nargs = 0 })

-- Search query using Google
vim.api.nvim_create_user_command("Google", function(o)
    local escaped = require("custom.url").encode(o.args)
    local url = ("https://www.google.com/search?q=%s"):format(escaped)
    vim.ui.open(url)
    print("Google search done!")
end, { nargs = 1, desc = "Search using google" })

-- Search query using DuckDuckGo
vim.api.nvim_create_user_command("DuckDuckGo", function(o)
    local escaped = require("custom.url").encode(o.args)
    local url = ("https://duckduckgo.com/?q=%s"):format(escaped)
    vim.ui.open(url)
    print("DuckDuckGo search done!")
end, { nargs = 1, desc = "Search using duckduckgo" })

-- Translate text using Google
vim.api.nvim_create_user_command("Translate", function(o)
    local src_lang = o.fargs[1]
    local target_lang = o.fargs[2]

    local text = ""
    if o.range ~= 0 then
        local v_start_pos         = vim.fn.getpos("'<")
        local v_start_line        = v_start_pos[2]
        local v_start_col         = v_start_pos[3]

        local v_end_pos           = vim.fn.getpos("'>")
        local v_end_line          = v_end_pos[2]
        local v_end_col           = v_end_pos[3]

        local is_visual_selection = v_start_line == o.line1 and v_end_line == o.line2

        if is_visual_selection then
            if v_start_line == v_end_line then
                local line = vim.api.nvim_buf_get_lines(0, v_start_line - 1, v_start_line, false)[1]
                text = string.sub(line, v_start_col, v_end_col)
            else
                local lines   = vim.api.nvim_buf_get_lines(0, v_start_line - 1, v_end_line, false)
                lines[1]      = string.sub(lines[1], v_start_col)
                lines[#lines] = string.sub(lines[#lines], 1, v_end_col)
                text          = table.concat(lines, "\n")
            end
        else
            local lines = vim.api.nvim_buf_get_lines(0, o.line1 - 1, o.line2, false)
            text = table.concat(lines, "\n")
        end
    else
        text = table.concat(o.fargs, " ", 3, #o.fargs)
    end

    local escaped = require("custom.url").encode(text)
    local url = ("https://translate.google.com/?sl=%s&tl=%s&text=%s&op=translate"):format(src_lang, target_lang, escaped)

    vim.ui.open(url)
    print("Translation done!")
end, { nargs = "+", range = true, desc = "" })

-- Does HTTP requests that follow JetBrains http syntax
-- https://www.jetbrains.com/help/idea/exploring-http-syntax.html
vim.api.nvim_create_user_command("HttpRequest", function()
    require("custom.http").request()
end, { nargs = 0, desc = "Do Http request" })

vim.api.nvim_create_user_command("HttpCopy", function()
    require("custom.http").copy()
end, { nargs = 0, desc = "Copy curl command to clipboard" })

vim.api.nvim_create_user_command("HttpChange", function()
    require("custom.http").change_env()
end, { nargs = 0, desc = "Change HTTP environment" })

vim.api.nvim_create_user_command("HttpView", function()
    require("custom.http").select_from_cache()
end, { nargs = 0, desc = "View a previously done HTTP response" })

vim.api.nvim_create_user_command("HttpCacheClear", function()
    require("custom.http").clear_cache()
end, { nargs = 0, desc = "Clear the cache of HTTP responses" })

vim.api.nvim_create_user_command("HttpCookieClear", function()
    require("custom.http").clear_cookie()
end, { nargs = 0, desc = "Clear the saved cookie" })
