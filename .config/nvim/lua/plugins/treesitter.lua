-- Highlight, edit, and navigate code
-- Additional nvim-treesitter modules:
--	- Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
--	- Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
--	- Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function ()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c", "cpp", "dockerfile", "lua", "vim", "vimdoc", "query",
				"javascript", "typescript", "php", "html",
				"css", "angular", "bash", "json",
				"sql", "tsx", "yaml", "python", "editorconfig", "make",
				"markdown", "markdown_inline"
			},
			auto_install = true,
			sync_install = false,
			modules = {},
			ignore_install = {},
			highlight = {
				enable = true,
				disable = function (lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			match = {
				enable = true,
			},
			indent = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<Leader>ss",
					node_incremental = "<Leader>si",
					scope_incremental = "<Leader>sc",
					node_decremental = "<Leader>sd",
				},
			},
			textobjects = {
				swap = {
					enable = true,
					swap_next = { ["<Leader>>"] = "@parameter.inner" },
					swap_previous = { ["<Leader><"] = "@parameter.inner" },
				},
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]]"] = "@jsx.element",
						["]f"] = "@function.outer",
						["]m"] = "@class.outer",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]M"] = "@class.outer",
					},
					goto_previous_start = {
						["[["] = "@jsx.element",
						["[f"] = "@function.outer",
						["[m"] = "@class.outer",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[M"] = "@class.outer",
					},
				},
			},
		})
	end,
}
