-- LSP Configuration & Plugins
-- See `:help lspconfig-all`
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- https://microsoft.github.io/language-server-protocol/implementors/servers/
return {
    -- `lazydev` configures Lua LSP for the Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {

        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs to "data" stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            { "j-hui/fidget.nvim", opts = {} },

            -- Allows extra capabilities provided by blink
            "saghen/blink.cmp",
        },
        config = function()
            --  This function gets run when an LSP attaches to a particular buffer.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(args)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
                    end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    if not client then
                        return
                    end

                    -- Find references for the word under your cursor.
                    map("grr", function() require("telescope.builtin").lsp_references({ include_declaration = false }) end,
                        "[G]oto [R]eferences")

                    --- Displays hover information about the symbol under the cursor in a floating window
                    map("K", function() vim.lsp.buf.hover({ border = "single" }) end, "Show symbol info")

                    -- Jump to the implementation of the word under your cursor.
                    -- Useful when your language has ways of declaring types without an actual implementation.
                    map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                    -- Fuzzy find all the symbols in your current document.
                    -- Symbols are things like variables, functions, types, etc.
                    -- The default keymap is "g0"
                    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

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
                        map("<leader>ff", function() vim.lsp.buf.format({ buf = args.buf, id = client.id }) end,
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
                            buffer = args.buf,
                            group = highlight_augroup,
                            callback = function()
                                local buffer_visible = vim.fn.bufwinnr(args.buf) ~= -1

                                if buffer_visible then
                                    vim.lsp.buf.document_highlight()
                                end
                            end,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = args.buf,
                            group = highlight_augroup,
                            callback = function()
                                local buffer_visible = vim.fn.bufwinnr(args.buf) ~= -1

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

                    -- The following autocommand is used to enable inlay hints in your
                    -- code, if the language server you are using supports them
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
                        end, "[T]oggle Inlay [H]ints")
                    end
                end,
            })


            vim.keymap.set("n", "<leader>sc", function() vim.lsp.stop_client(vim.lsp.get_clients()) end,
                { desc = "[S]top [C]lients" })

            vim.diagnostic.config({ float = { border = "single" } })

            -- LSP servers and clients are able to communicate to each other what features they support.
            -- By default, Neovim doesn't support everything that is in the LSP specification.
            -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
            -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

            -- LSP servers to enable
            -- Additional override configuration in the following tables.
            -- Available keys are:
            -- - cmd (table): Override the default command used to start the server
            -- - filetypes (table): Override the default list of associated filetypes for the server
            -- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
            -- - settings (table): Override the default settings passed when initializing the server.
            local servers = {
                basedpyright = {},
                clangd = {},
                phpactor = {},
                lua_ls = {},
                tailwindcss = {},
                css_variables = {},
                cssls = {},
                jsonls = {},
                html = {},
            }

            ---@diagnostic disable-next-line: missing-fields
            require("mason").setup({ ui = { border = "single" } })
            require("mason-lspconfig").setup()

            require('lspconfig.ui.windows').default_options = {
                border = "single"
            }

            for server_name, server_settings in pairs(servers) do
                server_settings.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_settings.capabilities or {})
                server_settings.on_init = function(client, _)
                    client.server_capabilities.semanticTokensProvider = nil
                end
                require("lspconfig")[server_name].setup(server_settings)
            end
        end,
    },
    {
        "pmizio/typescript-tools.nvim",
        ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

            require("typescript-tools").setup({
                on_init = function(client, _)
                    client.server_capabilities.semanticTokensProvider = nil
                end,
                capabilities = capabilities,
                settings = {
                    separate_diagnostic_server = false,
                    complete_function_calls = false,
                    expose_as_code_action = "all",
                },
            })

            vim.keymap.set("n", "<leader>ri", vim.cmd.TSToolsRemoveUnusedImports, { desc = "[R]emove [I]mports" })
            vim.keymap.set("n", "<leader>ai", vim.cmd.TSToolsAddMissingImports, { desc = "[A]dd missing [I]mports" })
            vim.keymap.set("n", "<leader>ru", vim.cmd.TSToolsRemoveUnused, { desc = "[R]emove [U]nused statements" })
            vim.keymap.set("n", "<leader>rf", vim.cmd.TSToolsRenameFile, { desc = "[R]ename [F]ile" })
            vim.keymap.set("n", "<leader>oi", vim.cmd.TSToolsOrganizeImports, { desc = "[O]rganize [I]mports" })
            vim.keymap.set("n", "<leader>fr", vim.cmd.TSToolsFileReferences, { desc = "[F]ile [R]eferences" })
        end
    },
}
