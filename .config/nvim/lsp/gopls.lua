-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gopls.lua
---@type vim.lsp.Config
return {
    cmd = { "gopls" },

    filetypes = { "go", "gomod", "gowork", "gotmpl" },

    workspace_required = true,

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { "go.work", "go.mod", ".git" })
    end,
}
