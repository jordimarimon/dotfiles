-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
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
        vim.keymap.set("n", "<leader>hr", function() harpoon:list():remove() end, { desc = "[H]arpoon [R]emove" })
        vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "[H]arpoon [C]lear" })
        vim.keymap.set("n", "<leader>hl", function() toggle_telescope(harpoon:list()) end, { desc = "[H]arpoon [L]ist" })
        vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "[H]arpoon navigate [P]revious" })
        vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "[H]arpoon navigate [N]ext" })

        -- Set <space>1..<space>5 for moving between files
        for _, idx in ipairs { 1, 2, 3, 4, 5 } do
            vim.keymap.set("n", string.format("<space>%d", idx), function() harpoon:list():select(idx) end)
        end
    end,
}
