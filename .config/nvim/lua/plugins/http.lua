return {
    {
        src = "https://github.com/mistweaverco/kulala.nvim",
        setup = function()
            require("kulala").setup({
                default_env = "dev",
                ui = {
                    display_mode = "float",
                },
                lsp = {
                    enable = false,
                },
            })
        end,
    },
}
