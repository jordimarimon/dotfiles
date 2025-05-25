-- autopairs
-- https://github.com/windwp/nvim-autopairs
return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = { {"nvim-treesitter/nvim-treesitter", branch = "main"} },
        event = "InsertEnter",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    }
}
