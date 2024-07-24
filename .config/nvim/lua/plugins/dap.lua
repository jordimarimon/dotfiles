-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/rcarriga/nvim-dap-ui
-- https://github.com/jay-babu/mason-nvim-dap.nvim
return {
	'mfussenegger/nvim-dap',
	dependencies = {
		-- Creates a beautiful debugger UI
		'rcarriga/nvim-dap-ui',

		-- Required dependency for nvim-dap-ui
		'nvim-neotest/nvim-nio',

		-- Installs the debug adapters
		'williamboman/mason.nvim',
		'jay-babu/mason-nvim-dap.nvim',
	},
	config = function ()
		local dap = require("dap")
		local dapui = require("dapui")

		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- A list of adapters to install if they're not already installed.
			ensure_installed = {},

			-- To provide additional configuration to the handlers.
			-- See mason-nvim-dap README for more information
			-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
			handlers = {
				function(config)
					-- all sources with no handler get passed here
					-- Keep original functionality
					require('mason-nvim-dap').default_setup(config)
				end,
				-- firefox = function (config)
				-- 	config.configurations.typescript = {
				-- 		{
				-- 			name = "Debug with Firefox",
				-- 			type = "firefox",
				-- 			request = "launch",
				-- 			reAttach = true,
				-- 			url = "http://localhost:4200",
				-- 			webRoot = "${workspaceFolder}",
				-- 			firefoxExecutable = "/usr/bin/firefox"
				-- 		},
				-- 	}
				--
				-- 	require('mason-nvim-dap').default_setup(config)
				-- end
			},
		})

		-- Basic debugging keymaps
		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
		end, { desc = "Debug: Set Breakpoint" })

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup()

		-- Toggle to see last session result. 
		-- Without this, one can't see session output in case of an unhandled exception.
		vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

		-- nvim-dap events to open and close the windows automatically
		-- see |:help dap-extensions|
		dap.listeners.before.attach.dapui_config = dapui.open
		dap.listeners.before.launch.dapui_config = dapui.open
		dap.listeners.before.event_terminated.dapui_config = dapui.close
		dap.listeners.before.event_exited.dapui_config = dapui.close
	end,
}
