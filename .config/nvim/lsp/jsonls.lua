-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua
---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },

    filetypes = { "json", "jsonc" },

    root_markers = { ".git" },

    init_options = {
        provideFormatter = true,
    },

    settings = {
        validate = false,
    },
}
