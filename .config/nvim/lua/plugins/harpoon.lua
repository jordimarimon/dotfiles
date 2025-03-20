-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()

        harpoon:extend({
            UI_CREATE = function(cx)
                vim.keymap.set("n", "<C-v>", function()
                    harpoon.ui:select_menu_item({ vsplit = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-x>", function()
                    harpoon.ui:select_menu_item({ split = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-t>", function()
                    harpoon.ui:select_menu_item({ tabedit = true })
                end, { buffer = cx.bufnr })
            end,
        })

        vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[H]arpoon [A]dd" })
        vim.keymap.set("n", "<leader>hr", function() harpoon:list():remove() end, { desc = "[H]arpoon [R]emove" })
        vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "[H]arpoon [C]lear" })
        vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "[H]arpoon [L]ist" })
        vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end,
            { desc = "[H]arpoon navigate [P]revious" })
        vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "[H]arpoon navigate [N]ext" })

        -- Set <space>1..<space>5 for moving between files
        for _, idx in ipairs { 1, 2, 3, 4, 5 } do
            vim.keymap.set("n", string.format("<space>%d", idx), function() harpoon:list():select(idx) end)
        end
    end,
}
