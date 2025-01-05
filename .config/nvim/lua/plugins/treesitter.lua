-- Highlight, edit, and navigate code
-- Additional nvim-treesitter modules:
--  - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--  - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
-- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "nvim-treesitter/nvim-treesitter-context",
        },
        config = function()
            local configs = require("nvim-treesitter.configs")
            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            local context = require("treesitter-context")

            parser_config.css = {
                filetype = "css",
                install_info = {
                    url = "~/Projects/tree-sitter-css",
                    files = { "src/parser.c", "src/scanner.c" },
                    branch = "master",
                    generate_requires_npm = false,
                    requires_generate_from_grammar = false,
                },
            }

            configs.setup({
                ensure_installed = {
                    "c", "cpp", "dockerfile", "lua", "vim", "vimdoc", "query",
                    "javascript", "typescript", "php", "html",
                    "css", "angular", "bash", "json",
                    "sql", "tsx", "yaml", "python", "editorconfig", "make",
                    "markdown", "markdown_inline"
                },
                auto_install = false,
                sync_install = false,
                modules = {},
                ignore_install = {},
                highlight = {
                    enable = true,
                },
                match = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<Leader>ss",
                        node_incremental = "<Leader>si",
                        scope_incremental = "<Leader>sc",
                        node_decremental = "<Leader>sd",
                    },
                },
                textobjects = {
                    swap = {
                        enable = true,
                        swap_next = { ["<Leader>>"] = "@parameter.inner" },
                        swap_previous = { ["<Leader><"] = "@parameter.inner" },
                    },
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]]"] = "@jsx.element",
                            ["]f"] = "@function.outer",
                            ["]m"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]F"] = "@function.outer",
                            ["]M"] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[["] = "@jsx.element",
                            ["[f"] = "@function.outer",
                            ["[m"] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[F"] = "@function.outer",
                            ["[M"] = "@class.outer",
                        },
                    },
                },
            })

            context.setup({
                enable = false,
                mode = 'topline',
                on_attach = function(bufnr)
                    return vim.bo[bufnr].filetype ~= "markdown"
                end,
            })
        end,
    },
    {
        "Wansmer/treesj",
        keys = { "<leader>ts", "<leader>tj" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesj").setup({
                use_default_keympas = false,
            })

            vim.keymap.set("n", "<leader>ts", function() require("treesj").split() end, { desc = "[T]reesitter [S]plit" })
            vim.keymap.set("n", "<leader>tj", function() require("treesj").join() end, { desc = "[T]reesitter [J]oin" })
        end,
    }
}
