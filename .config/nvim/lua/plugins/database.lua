-- https://github.com/tpope/vim-dadbod
-- https://github.com/kristijanhusak/vim-dadbod-ui
-- https://github.com/kristijanhusak/vim-dadbod-completion
return {
    {
        src = "https://github.com/tpope/vim-dadbod",
    },
    {
        src = "https://github.com/kristijanhusak/vim-dadbod-completion",
    },
    {
        src = "https://github.com/kristijanhusak/vim-dadbod-ui",
        setup = function()
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },
}
