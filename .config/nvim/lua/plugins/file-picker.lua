-- Fuzzy Finder (files, lsp, etc)
return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf_lua = require("fzf-lua")

        fzf_lua.register_ui_select()

        fzf_lua.setup({
            winopts = {
                border = "single",
                preview = {
                    layout = "vertical",
                },
            },
            fzf_colors = true,
            hls = {
                path_colnr = "qfLineNr",
                path_linenr = "qfLineNr",
                header_text = "Normal",
                header_bind = "Normal",
                buf_flag_alt = "Normal",
                buf_flag_cur = "Normal",
                tab_title = "Normal",
                tab_marker = "Normal",
                live_prompt = "Normal",
                live_sym = "Normal",
            },
            keymap = {
                builtin = {
                    ["<C-e>"] = "hide",
                    ["<C-f>"] = "preview-page-down",
                    ["<C-b>"] = "preview-page-up",
                    ["<C-d>"] = "preview-down",
                    ["<C-u>"] = "preview-up",
                },
                fzf = {
                    ["ctrl-q"] = "select-all+accept",
                    ["alt-l"] = "select-all", -- Combined with the action
                },
            },
            actions = {
                files = {
                    ["enter"] = fzf_lua.actions.file_edit_or_qf,
                    ["ctrl-x"] = fzf_lua.actions.file_split,
                    ["ctrl-v"] = fzf_lua.actions.file_vsplit,
                    ["ctrl-t"] = fzf_lua.actions.file_tabedit,
                    ["alt-q"] = fzf_lua.actions.file_sel_to_qf,
                    ["alt-l"] = fzf_lua.actions.file_sel_to_ll,
                },
            },
            grep = {
                rg_opts = "--column --line-number --multiline --no-heading --color=never --smart-case --max-columns=4096 -e",
            },
            buffers = {
                actions = {
                    ["ctrl-x"] = fzf_lua.actions.buf_split,
                    ["alt-d"] = {
                        fn = fzf_lua.actions.buf_del,
                        reload = true,
                    },
                },
            },
        })

        vim.keymap.set("n", "<leader>sf", fzf_lua.files, { desc = "Search files" })
        vim.keymap.set("n", "<leader>sb", fzf_lua.buffers, { desc = "Search buffers" })
        vim.keymap.set("n", "<leader>sr", fzf_lua.resume, { desc = "Resume previous search" })
        vim.keymap.set(
            "n",
            "<leader>sd",
            fzf_lua.diagnostics_workspace,
            { desc = "Search diagnostics" }
        )
        vim.keymap.set("n", "<leader>sg", fzf_lua.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>sm", fzf_lua.marks, { desc = "Search marks" })
        vim.keymap.set("n", "<leader>sk", fzf_lua.keymaps, { desc = "Search keymaps" })
        vim.keymap.set("n", "<leader>sh", fzf_lua.helptags, { desc = "Search help" })
        vim.keymap.set("n", "<leader>st", fzf_lua.tags, { desc = "Search tags" })
        vim.keymap.set("n", "<leader>sj", fzf_lua.jumps, { desc = "Search jumps" })
        vim.keymap.set("n", "<leader>sc", fzf_lua.commands, { desc = "Search command" })
        vim.keymap.set(
            "n",
            "<leader>sch",
            fzf_lua.command_history,
            { desc = "Search command history" }
        )
        vim.keymap.set("n", "<leader>sgh", fzf_lua.git_hunks, { desc = "Search git hunks" })
    end,
}
