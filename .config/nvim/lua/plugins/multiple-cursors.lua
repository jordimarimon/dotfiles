return {
	"mg979/vim-visual-multi",
	branch = "master",
	config = function ()
		-- :help visual-multi
		-- :help vm-mappings-all
		-- :help vm-settings
		vim.g.VM_maps = {
			["Add Cursor Up"] = "<C-k>",
			["Add Cursor Down"] = "<C-j>",
		}
	end
}
