-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },

    filetypes = { "lua" },

    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = false,
                ignoreSubmodules = true,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
            telemetry = {
                enable = false,
            },
        },
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, {
            "init.lua",
            ".luarc.json",
            ".luarc.jsonc",
            ".luacheckrc",
            ".stylua.toml",
            "stylua.toml",
            "selene.toml",
            "selene.yml",
            ".git",
        })
    end,
}
