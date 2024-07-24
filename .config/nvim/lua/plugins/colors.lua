return {
	"brenoprata10/nvim-highlight-colors",
	cmd = "HighlightColors",
	keys = {
		{ "<leader>ct", "<cmd>HighlightColors Toggle<cr>", desc = "Highlight [C]olors [T]oggle" },
	},
	config = function ()
		local hl_colors = require("nvim-highlight-colors")

		hl_colors.setup({render = "virtual"})
		hl_colors.turnOff()
	end
}
