return {
    {
        src = "https://github.com/obsidian-nvim/obsidian.nvim",
        version = vim.version.range("*"),
        setup = function()
            require("obsidian").setup({
                legacy_commands = false,
                workspaces = {
                    {
                        name = "hooba",
                        path = "~/Hooba/docs",
                    },
                },
                picker = {
                    name = "fzf-lua",
                },
            })
        end,
    },
}
