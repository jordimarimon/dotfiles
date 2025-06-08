---@return string[]
local get_active_clients = function()
    ---@param client vim.lsp.Client
    ---@return string
    local get_client_name = function(client) return client.name end

    return vim.tbl_map(get_client_name, vim.lsp.get_clients())
end

-- Configure keymaps and some functionalities when LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(args)
        local client_id = args.data.client_id
        local buf = args.buf
        local client = vim.lsp.get_client_by_id(client_id)

        if not client then
            return
        end

        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = buf, desc = "LSP: " .. desc })
        end


        -- Find references for the word under your cursor.
        map("grr", function() require("telescope.builtin").lsp_references({ include_declaration = false }) end,
            "[G]oto [R]eferences")

        --- Displays hover information about the symbol under the cursor in a floating window
        map("K", function() vim.lsp.buf.hover({ border = "single" }) end, "Show symbol info")

        map("<C-s>", function() vim.lsp.buf.signature_help({ border = "single" }) end, "Show signature help",
            { "n", "i" })

        -- Jump to the implementation of the word under your cursor.
        -- Useful when your language has ways of declaring types without an actual implementation.
        map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

        -- Fuzzy find all the symbols in your current document.
        -- Symbols are things like variables, functions, types, etc.
        map("gO", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

        -- Jump to the definition of the word under your cursor.
        -- This is where a variable was first declared, or where a function is defined, etc.
        -- To jump back, press <C-t>.
        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

        -- This is not Goto Definition, this is Goto Declaration.
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Jump to the type of the word under your cursor.
        -- Useful when you"re not sure what type a variable is and you want to see
        -- the definition of its *type*, not where it was *defined*.
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

        -- Format file
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
            map("<leader>ff", function() vim.lsp.buf.format({ buf = buf, id = client.id }) end,
                "[F]ormat [F]ile", { "n" })
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = buf,
                group = highlight_augroup,
                callback = function()
                    local buffer_visible = vim.fn.bufwinnr(buf) ~= -1

                    if buffer_visible then
                        vim.lsp.buf.document_highlight()
                    end
                end,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = buf,
                group = highlight_augroup,
                callback = function()
                    local buffer_visible = vim.fn.bufwinnr(buf) ~= -1

                    if buffer_visible then
                        vim.lsp.buf.clear_references()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
                end,
            })
        end

        -- The following keymap is used to enable inlay hints
        -- if the language server you are using supports them
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
            end, "[T]oggle Inlay [H]ints")
        end

        -- Enable colors
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentColor) then
            vim.lsp.document_color.enable(true, buf, { style = "virtual" })
        end

        -- Enable LSP folding
        -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
        --     local win = vim.api.nvim_get_current_win()
        --     vim.wo[win][0].foldmethod = "expr"
        --     vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        -- end

        -- Enable builtin auto-completion
        -- if client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
        --   vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
        -- end
    end,
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

        print("LSP " .. client.name .. " closed!")

        client:stop()
    end,
})

-- LSP logs
vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd(string.format("tabnew %s", vim.lsp.get_log_path()))
end, { desc = "Opens the Nvim LSP client log." })

-- LSP info
vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })

-- To start again the client just use ":e!"
vim.api.nvim_create_user_command("LspStop", function(info)
    local args = info.args

    if #args == 0 then
        if info.bang then
            vim.lsp.stop_client(vim.lsp.get_clients())
        else
            vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() }))
        end
    else
        for _, client in ipairs(vim.lsp.get_clients()) do
            for _, name in ipairs(info.fargs) do
                if name == client.name then
                    client:stop(info.bang)
                    break
                end
            end
        end
    end
end, { nargs = "*", bang = true, desc = "Stops LSP clients", complete = get_active_clients })

-- Add border when showing diagnostics in a floting popup,
-- and also color the linenumber instead of addding a sign
vim.diagnostic.config({
    float = {
        border = "single",
    },
    virtual_text = true,
    virtual_lines = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = 'WarningMsg',
            [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
            [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
            [vim.diagnostic.severity.HINT] = 'DiagnosticHint',

        },
    },
})

-- Load all LSP's
local lsp_path = vim.fn.stdpath("config") .. "/lsp"
for _, file in ipairs(vim.fn.readdir(lsp_path)) do
    -- `:t` gets filename, `:r` removes extension
    local name = vim.fn.fnamemodify(file, ":t:r")
    vim.lsp.enable(name)
end
