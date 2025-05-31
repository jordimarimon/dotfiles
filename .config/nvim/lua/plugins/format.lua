return {
    {
        "stevearc/conform.nvim",
        opts = {},
        config = function()
            require("conform").setup({
                format_on_save = {
                    timeout_ms = 5000,
                    lsp_format = "never",
                },
                formatters_by_ft = {
                    javascript = { "prettier" },
                    javascriptreact = { "prettier" },
                    typescript = { "prettier" },
                    typescriptreact = { "prettier" },
                    html = { "prettier" },
                    htmlangular = { "prettier" },
                    json = { "prettier" },
                    markdown = { "prettier" },
                    go = { "goimports", "gofmt" },
                },
            })
        end
    },

    -- Detect tabstop and shiftwidth automatically
    {
        "tpope/vim-sleuth",
    },
}
