-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[H]arpoon [A]dd" })
		vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "[H]arpoon [C]lear" })
		vim.keymap.set("n", "<leader>ht", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[H]arpoon [T]oggle" })
		vim.keymap.set("n", "<leader>hn", function() harpoon:list():prev() end, { desc = "[H]arpoon navigate [N]ext" })
		vim.keymap.set("n", "<leader>hp", function() harpoon:list():next() end, { desc = "[H]arpoon navigate [P]revious" })
	end,
}
