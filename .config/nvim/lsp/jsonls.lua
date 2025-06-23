-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua
---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },

    filetypes = { "json", "jsonc" },

    init_options = {
        provideFormatter = true,
    },

    settings = {
        validate = false,
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { ".git" })
    end,
}
