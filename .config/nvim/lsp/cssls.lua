-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/cssls.lua
---@type vim.lsp.Config
return {
    cmd = { "vscode-css-language-server", "--stdio" },

    filetypes = { "css", "scss", "less" },

    init_options = { provideFormatter = true }, -- needed to enable formatting capabilities

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { "package.json", ".git" })
    end,

    settings = {
        css = {
            validate = false,
        },
        less = {
            validate = false,
        },
        scss = {
            validate = false,
        }
    },
}
