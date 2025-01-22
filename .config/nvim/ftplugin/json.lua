-- Shows outdated dependencies for NPM
vim.keymap.set("n", "<leader>od", function()
    require("custom.npm-outdated").toggle()
end, { desc = "[O]utdated [D]ependencies", buffer = true })
