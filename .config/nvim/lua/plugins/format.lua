return {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
        require("conform").setup({
            format_on_save = {
                timeout_ms = 1000,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptrect = { "prettier" },
                html = { "prettier" },
                htmlangular = { "prettier" },
                css = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
            },
        })
    end
}
