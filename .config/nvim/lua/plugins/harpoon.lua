-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	config = function()
		local conf = require("telescope.config").values
		local harpoon = require("harpoon")
		harpoon:setup()

		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers").new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({
					results = file_paths,
				}),
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter({}),
			}):find()
		end

		vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[H]arpoon [A]dd" })
		vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "[H]arpoon [C]lear" })
		vim.keymap.set("n", "<leader>ht", function() toggle_telescope(harpoon:list()) end, { desc = "[H]arpoon [T]oggle" })
		vim.keymap.set("n", "<leader>hn", function() harpoon:list():prev() end, { desc = "[H]arpoon navigate [N]ext" })
		vim.keymap.set("n", "<leader>hp", function() harpoon:list():next() end, { desc = "[H]arpoon navigate [P]revious" })
	end,
}
