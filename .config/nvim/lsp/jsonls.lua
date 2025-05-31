-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua
---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    init_options = {
        provideFormatter = true,
    },
    root_markers = { ".git" },
}
