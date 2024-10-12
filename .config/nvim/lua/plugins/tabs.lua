return {
	"nanozuki/tabby.nvim",
	event = "VimEnter",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		require("tabby").setup({
			line = function (line)
				return {
					line.tabs().foreach(
						function (tab)
							local hl = tab.is_current() and { fg = "#000000", bg = "#FFFFFF", style = "bold" } or { fg = "#FFFFFF", bg = "#040299" }
							return {
								{ " ", hl = hl },
								tab.is_current() and " " or " ",
								tab.number(),
								tab.close_btn(""),
								{ " ", hl = hl },
								hl = hl,
								margin = " ",
							}
						end
					)
				}
			end
		})

		vim.api.nvim_set_keymap("n", "<M-h>", ":tabp<CR>", { silent = true, noremap = true })
		vim.api.nvim_set_keymap("n", "<M-l>", ":tabn<CR>", { silent = true, noremap = true })
		vim.api.nvim_set_keymap("n", "<M-S-h>", ":-tabmove<CR>", { silent = true, noremap = true, desc = "[T]ab [M]ove [P]revious" })
		vim.api.nvim_set_keymap("n", "<M-S-l>", ":+tabmove<CR>", { silent = true, noremap = true, desc  = "[T]ab [M]ove [N]ext" })
	end,
}
