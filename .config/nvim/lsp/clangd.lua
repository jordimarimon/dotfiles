-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua
---@type vim.lsp.Config
return {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--log=verbose" },

    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },

    workspace_required = true,

    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { "utf-8", "utf-16" },
    },

    root_dir = function(bufnr, on_dir)
        require("custom.lsp").root_dir(bufnr, on_dir, {
            ".clangd",
            ".clang-tidy",
            ".clang-format",
            "compile_commands.json",
            "compile_flags.txt",
            "configure.ac", -- AutoTools
            ".git",
        })
    end,

    on_init = function(client, _)
        client.server_capabilities.semanticTokensProvider = nil
    end,
}
