-- set the colorscheme
vim.cmd.colorscheme('light')

-- define options
require("options")

-- define plugins
require("plugins")
require("lazy").setup({
  {import = "plugins.telescope"},
  {import = "plugins.treesitter"},
  {import = "plugins.sleuth"},
  {import = "plugins.mason"},
  {import = "plugins.lsp"},
  {import = "plugins.completion"},
  {import = "plugins.todo-comments"},
  {import = "plugins.neo-tree"},
  {import = "plugins.gitsigns"},
  {import = "plugins.mini"},
  {import = "plugins.autopairs"},
  {import = "plugins.fugitive"},
  {import = "plugins.which-key"},
  {import = "plugins.harpoon"},
}, {})

-- define keymaps
require("keymaps")

-- define autocommands
require("autocmds")

-- See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

