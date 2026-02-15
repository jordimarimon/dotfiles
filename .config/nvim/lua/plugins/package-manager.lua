-- Automatically install LSPs to "data" stdpath for neovim
return {
    "mason-org/mason.nvim",
    config = function()
        local registry = require("mason-registry")
        local packages = {
            "basedpyright",
            "bash-language-server",
            "clang-format",
            "clangd",
            "css-lsp",
            "css-variables-language-server",
            "goimports",
            "gopls",
            "html-lsp",
            "intelephense",
            "json-lsp",
            "lua-language-server",
            "typescript-language-server",
            "tsgo",
            "yaml-language-server",
        }

        ---@diagnostic disable-next-line: missing-fields
        require("mason").setup({ ui = { border = "single" } })

        registry.refresh(function(success)
            if not success then
                return
            end

            local packages_to_install = {}

            for _, pkg in ipairs(packages) do
                if not registry.is_installed(pkg) then
                    table.insert(packages_to_install, pkg)
                end
            end

            if #packages_to_install > 0 then
                vim.cmd("MasonInstall " .. table.concat(packages_to_install, " "))
            end
        end)
    end,
}
