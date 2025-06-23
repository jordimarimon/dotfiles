-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/basedpyright.lua
---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },

    filetypes = { "python" },

    workspace_required = true,

    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "off",
            },
        },
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
        })
    end,

    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(0, "OrganizeImports", function()
            client:exec_cmd({
                title = "Organize Imports",
                command = "basedpyright.organizeimports",
                arguments = { vim.uri_from_bufnr(bufnr) },
            })
        end, { desc = "Organize Imports" })
    end,
}
