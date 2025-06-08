-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gopls.lua
---@type vim.lsp.Config
return {
    cmd = { "gopls" },

    filetypes = { "go", "gomod", "gowork", "gotmpl" },

    workspace_required = true,

    root_markers = { "go.work", "go.mod", ".git" },
}
