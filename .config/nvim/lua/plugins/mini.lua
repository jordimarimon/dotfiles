return {
    "nvim-mini/mini.nvim",
    config = function()
        require("mini.ai").setup({ n_lines = 500 })

        require("mini.surround").setup({
            custom_surroundings = {
                ["("] = { output = { left = "(", right = ")" } },
                ["["] = { output = { left = "[", right = "]" } },
                ["{"] = { output = { left = "{", right = "}" } },
                ["<"] = { output = { left = "<", right = ">" } },
            },
        })

        -- Allows moving lines using Alt + hjkl
        require("mini.move").setup()

        -- Allows aligning text horizontally
        require("mini.align").setup()

        -- Highlight some patterns
        require("mini.hipatterns").setup({
            highlighters = {
                fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
            },
        })

        -- Simple and easy statusline.
        local statusline = require("mini.statusline")
        statusline.setup({ use_icons = true })

        -- Set the section for cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end
    end,
}
