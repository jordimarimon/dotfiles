-- Collection of various small independent plugins/modules
return {
	'echasnovski/mini.nvim',
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext ["]quote
		--  - ci"  - [C]hange [I]nside ["]quote
		require("mini.ai").setup({n_lines = 500})

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd"   - [S]urround [D]elete ["]quotes
		-- - sr)"  - [S]urround [R]eplace [)] ["]
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

		-- You can configure sections in the statusline by overriding their
		-- default behavior. For example, here we set the section for
		-- cursor location to LINE:COLUMN
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
