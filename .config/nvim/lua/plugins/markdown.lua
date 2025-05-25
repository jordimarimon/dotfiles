return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            {"nvim-treesitter/nvim-treesitter", branch = "main"},
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("render-markdown").setup({
                code = {
                    above = "",
                    below = "",
                },
            })
        end
    },
}
