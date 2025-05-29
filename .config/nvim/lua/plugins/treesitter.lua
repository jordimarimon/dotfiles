-- Highlight, edit, and navigate code
-- Additional nvim-treesitter modules:
--  - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--  - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
-- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter").setup()
            require("nvim-treesitter").install({
                -- https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers
                "angular",
                "bash",
                "c",
                "cmake",
                "cpp",
                "css",
                "dockerfile",
                "editorconfig",
                "gitcommit",
                "gitignore",
                "git_rebase",
                "go",
                "gomod",
                "gosum",
                "haskell",
                "html",
                "http",
                "javascript",
                "json",
                "json5",
                "jsonc",
                "lua",
                "make",
                "markdown",
                "meson",
                "nginx",
                "ninja",
                "php",
                "python",
                "query",
                "rust",
                "sql",
                "sway",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
                "zsh",
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        config = function()
            -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                }
            })

            vim.keymap.set({ "x", "o" }, "af", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
            end)

            vim.keymap.set({ "x", "o" }, "if", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
            end)

            vim.keymap.set({ "x", "o" }, "as", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
            end)
        end,
    },
    {
        "Wansmer/treesj",
        keys = { "<leader>ts", "<leader>tj" },
        dependencies = { "nvim-treesitter/nvim-treesitter", branch = "main" },
        config = function()
            require("treesj").setup({
                use_default_keymaps = false,
            })

            vim.keymap.set("n", "<leader>ts", function() require("treesj").split() end, { desc = "[T]reesitter [S]plit" })
            vim.keymap.set("n", "<leader>tj", function() require("treesj").join() end, { desc = "[T]reesitter [J]oin" })
        end,
    }
}
