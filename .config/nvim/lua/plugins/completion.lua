-- Autocompletion
return {
    "saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    config = function()
        require("blink.cmp").setup({
            -- "default" for mappings similar to built-in completion
            keymap = {
                preset = "default",
                ["<Tab>"] = {},
                ["<S-Tab>"] = {},
                ["<C-k>"] = {},
                ["<M-l>"] = { "snippet_forward", "fallback" },
                ["<M-h>"] = { "snippet_backward", "fallback" },
            },

            cmdline = {
                completion = {
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":" or vim.fn.getcmdtype() == "@"
                        end,
                    },
                },
                keymap = {
                    ["<Tab>"] = {},
                    ["<S-Tab>"] = {},
                    ["<C-space>"] = {
                        function(cmp)
                            if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then return cmp.accept() end
                        end,
                        "show",
                    },
                    ["<C-n>"] = { "select_next", "fallback" },
                    ["<C-p>"] = { "select_prev", "fallback" },
                },
            },

            -- Default list of enabled providers
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },

                per_filetype = {
                    sql = { "dadbod" },
                    mysql = { "dadbod" },
                    plsql = { "dadbod" },
                },

                providers = {
                    lsp = {
                        min_keyword_length = 0,
                        score_offset = 0,
                    },
                    path = {
                        min_keyword_length = 0,
                    },
                    snippets = {
                        min_keyword_length = 1,
                    },
                    buffer = {
                        min_keyword_length = 0,
                        max_items = 5,
                    },
                    dadbod = {
                        name = "dadbod",
                        module = "vim_dadbod_completion.blink"
                    },
                },
            },

            completion = {
                -- Add borders around floating windows
                menu = {
                    border = "single",
                    draw = {
                        treesitter = { "lsp" },
                    },
                },

                documentation = {
                    window = {
                        border = "single",
                    },
                },

                -- Enable auto brackets
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
            },

            -- Signature help support
            signature = {
                enabled = false,
                window = {
                    border = "single",
                },
            },
        })
    end,
}
