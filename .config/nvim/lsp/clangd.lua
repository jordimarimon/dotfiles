-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua
---@type vim.lsp.Config
return {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--log=verbose" },

    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },

    root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
        ".git",
    },

    workspace_required = true,

    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { "utf-8", "utf-16" },
    },

    on_init = function(client, _)
        client.server_capabilities.semanticTokensProvider = nil
    end,
}
