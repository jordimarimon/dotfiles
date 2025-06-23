-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/html.lua
---@type vim.lsp.Config
return {
    cmd = { "vscode-html-language-server", "--stdio" },

    filetypes = { "html", "templ" },

    init_options = {
        provideFormatter = true,
        embeddedLanguages = { css = true, javascript = true },
        configurationSection = { "html", "css", "javascript" },
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { "package.json", ".git" })
    end,
}
