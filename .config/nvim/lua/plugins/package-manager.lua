-- Automatically install LSPs to "data" stdpath for neovim
return {
    "williamboman/mason.nvim",
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("mason").setup({ ui = { border = "single" } })
    end,
}
