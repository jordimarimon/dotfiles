return {
    "nvim-mini/mini.nvim",
    config = function()
        require("mini.ai").setup({ n_lines = 500 })

        require("mini.surround").setup({
            custom_surroundings = {
                ['('] = { output = { left = '(', right = ')' } },
                ['['] = { output = { left = '[', right = ']' } },
                ['{'] = { output = { left = '{', right = '}' } },
                ['<'] = { output = { left = '<', right = '>' } },
            },
        })

        -- Allows moving lines using Alt + hjkl
        require("mini.move").setup()

        -- Simple and easy statusline.
        local statusline = require("mini.statusline")
        statusline.setup({ use_icons = true })

        -- set the section for cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return "%2l:%-2v"
        end
    end,
}
