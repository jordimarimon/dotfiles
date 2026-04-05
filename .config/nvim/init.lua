-- set the colorscheme
vim.cmd.colorscheme("light")

-- define options
require("options")
require("tabs")
require("filetypes")

-- load plugins
require("plugins")

-- Enable the new experimental command-line features.
-- :help vim._core.ui2
require("vim._core.ui2").enable({ enable = true })

-- define keymaps
require("keymaps")

-- define autocommands
require("autocmds")

-- enable lsps
require("lsp")

-- See `:help modeline`
-- vim: ts=4 sts=4 sw=4 et
