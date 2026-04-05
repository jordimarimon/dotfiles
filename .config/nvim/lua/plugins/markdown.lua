return {
    {
        src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        setup = function()
            require("render-markdown").setup({
                latex = {
                    enabled = false,
                },
                code = {
                    language_border = "",
                    above = "",
                    below = "",
                    highlight_border = false,
                },
            })
        end,
    },
}
