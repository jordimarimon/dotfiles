-- Highlight todo, notes, etc in comments
return {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local todo_comments = require("todo-comments")
        todo_comments.setup({
            signs = false,
            highlight = {
                pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
            },
            search = {
                pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
            },
        })

        vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "[S]earch [T]odos", silent = true })
        vim.keymap.set("n", "]t", function() todo_comments.jump_next() end, { desc = "Next todo comment", silent = true })
        vim.keymap.set("n", "[t", function() todo_comments.jump_prev() end,
            { desc = "Previous todo comment", silent = true })
    end
}
