-- autopairs
-- https://github.com/windwp/nvim-autopairs
return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "iguanacucumber/magazine.nvim" },
		config = function()
			require("nvim-autopairs").setup({})
			-- To automatically add `(` after selecting a function or method
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function ()
			require("nvim-ts-autotag").setup()
		end,
	}
}
