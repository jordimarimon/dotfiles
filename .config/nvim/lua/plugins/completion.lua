-- Autocompletion
return {
	"saghen/blink.cmp",
    version = "*",
    build = "cargo build --release",
    dependencies = {
        { "folke/lazydev.nvim", ft = "lua" },
    },
    event = { "BufReadPost", "BufNewFile" },
	config = function()
        require("blink.cmp").setup({
            -- "default" for mappings similar to built-in completion
            keymap = {
                preset = "default",
                ["<Tab>"] = {},
                ["<S-Tab>"] = {},
                ["<M-l>"] = { "snippet_forward", "fallback" },
                ["<M-h>"] = { "snippet_backward", "fallback" },
            },

            -- Default list of enabled providers
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },

                cmdline = function()
                    local type = vim.fn.getcmdtype()

                    -- Search forward and backward
                    if type == "/" or type == "?" then
                        return { "buffer" }
                    end

                    -- Commands
                    if type == ":" then
                        return { "cmdline" }
                    end

                    return {}
                end,

                per_filetype = {
                    sql = { "dadbod" },
                    mysql = { "dadbod" },
                    plsql = { "dadbod" },
                },

                providers = {
                    lsp = {
                        min_keyword_length = 2,
                        score_offset = 0,
                    },
                    path = {
                        min_keyword_length = 0,
                    },
                    snippets = {
                        min_keyword_length = 2,
                    },
                    buffer = {
                        min_keyword_length = 5,
                        max_items = 5,
                    },
                    dadbod = {
                        name = "dadbod",
                        module = "vim_dadbod_completion.blink"
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
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
