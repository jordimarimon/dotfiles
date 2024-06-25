-- Highlight, edit, and navigate code
return {
	"nvim-treesitter/nvim-treesitter",
	build = ':TSUpdate',
	config = function ()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c", "lua", "vim", "vimdoc", "query",
				"javascript", "typescript", "php", "html",
				"css", "angular", "bash", "haskell", "json",
				"sql", "tsx", "yaml"
			},
			auto_install = true,
			sync_install = false,
			modules = {},
			highlight = { enable = true },
			indent = { enable = true },
			ignore_install = {},
		})
	end,
}
