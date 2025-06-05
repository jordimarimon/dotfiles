-- Highlight, edit, and navigate code
-- Additional nvim-treesitter modules:
--  - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--  - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
-- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = function()
            -- https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers
            local parsers_installed = {
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
            }

            require("nvim-treesitter").install(parsers_installed)
            require("nvim-treesitter").update()
        end,
        config = function()
            require("nvim-treesitter").setup()
        end,
        init = function()
            -- Enable treesitter highlighting and indentation
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local filetype = args.match
                    local lang = vim.treesitter.language.get_lang(filetype)

                    if lang ~= nil and vim.treesitter.language.add(lang) then
                        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        vim.treesitter.start()
                    end
                end
            })
        end,
    },

    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        config = function()
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

    -- Adds an easy way to split/join Treesitter nodes
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
    },

    -- Highlight todo, notes, etc in comments
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local todo_comments = require("todo-comments")
            todo_comments.setup({
                signs = false,
                highlight = {
                    pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
                },
                search = {
                    pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
                },
            })

            vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "[S]earch [T]odos", silent = true })
        end
    }
}
