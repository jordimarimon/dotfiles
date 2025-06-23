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
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, {
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
