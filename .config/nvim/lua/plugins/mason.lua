-- https://github.com/williamboman/mason.nvim
-- See `:h mason-quickstart`
return {
    "williamboman/mason.nvim",
    config = function()
	require("mason").setup()
    end,
}
