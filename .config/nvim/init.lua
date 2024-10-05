-- set the colorscheme
vim.cmd.colorscheme("light")

-- define options
require("options")
require("filetypes")

-- define plugins
require("plugins")
require("lazy").setup(
  {
    {import = "plugins.telescope"},
    {import = "plugins.treesitter"},
    {import = "plugins.sleuth"},
    {import = "plugins.lsp"},
    {import = "plugins.completion"},
    {import = "plugins.todo-comments"},
    {import = "plugins.neo-tree"},
    {import = "plugins.git"},
    {import = "plugins.mini"},
    {import = "plugins.autopairs"},
    {import = "plugins.markdown"},
    {import = "plugins.database"},
    {import = "plugins.colors"},
    {import = "plugins.oil"},
  },
  {
    ui = {border = "single"},
  }
)

-- define keymaps
require("keymaps")

-- define autocommands
require("autocmds")

-- See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

