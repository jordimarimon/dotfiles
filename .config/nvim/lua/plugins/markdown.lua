return {
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
