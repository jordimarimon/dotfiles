-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/intelephense.lua
---@type vim.lsp.Config
return {
    cmd = { "intelephense", "--stdio" },

    filetypes = { "php" },

    init_options = {
        licenceKey = function()
            local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
            local content = f:read("*a")
            f:close()
            return string.gsub(content, "%s+", "")
        end,
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { "composer.json", ".git" })
    end,
}
