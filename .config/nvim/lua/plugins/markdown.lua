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
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("render-markdown").setup({
                win_options = {
                    -- FIXME: Remove it when the glitch in insert mode dissapears
                    conceallevel = {
                        default = 0,
                        rendered = 0,
                    },
                },
                code = {
                    above = "",
                    below = "",
                },
            })
        end
    },
}
