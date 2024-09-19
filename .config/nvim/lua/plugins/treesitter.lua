-- Highlight, edit, and navigate code
-- Additional nvim-treesitter modules:
--	- Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--	- Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--	- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	config = function ()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c", "lua", "vim", "vimdoc", "query",
				"javascript", "typescript", "php", "html",
				"css", "scss", "angular", "bash", "haskell", "json",
				"sql", "tsx", "yaml", "python"
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
