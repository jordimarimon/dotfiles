local get_intelephense_license = function()
    local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
    local content = f:read("*a")
    f:close()
    return string.gsub(content, "%s+", "")
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/intelephense.lua
---@type vim.lsp.Config
return {
    cmd = { "intelephense", "--stdio" },

    filetypes = { "php" },

    settings = {
        -- https://intelephense.com/docs#configuration
        -- https://github.com/bmewburn/vscode-intelephense/blob/master/package.json#L149
        intelephense = {
            files = {
                exclude = {
                    "**/.git/**",
                    "**/.svn/**",
                    "**/.hg/**",
                    "**/CVS/**",
                    "**/.DS_Store/**",
                    "**/node_modules/**",
                    "**/bower_components/**",
                    "**/vendor/**/{Tests,tests}/**",
                    "**/.history/**",
                    -- "**/vendor/**/vendor/**",
                },
            },
        },
    },

    init_options = {
        licenceKey = get_intelephense_license(),
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, { "composer.json", ".git" })
    end,
}
