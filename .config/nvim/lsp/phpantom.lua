---@brief
---
--- https://github.com/AJenbo/phpantom_lsp
---
--- Installation: https://github.com/AJenbo/phpantom_lsp/blob/main/docs/SETUP.md

---@type vim.lsp.Config
return {
    cmd = { "phpantom_lsp" },

    filetypes = { "php" },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { ".git", "composer.json", ".phpantom.toml" })
    end,
}
