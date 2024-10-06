-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set highlight on search
vim.opt.hlsearch = false

-- Make line numbers default
vim.opt.number = true

-- Set line numbers to be relative
vim.opt.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Add support for hyperlinks
vim.opt.conceallevel = 2

-- Enable mouse mode
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  See `:help 'clipboard'`
vim.schedule(function ()
        vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Don't have `o` add a comment
vim.opt.formatoptions:remove "o"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 500

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,noselect"

-- Enables 24-bit RGB color in the TUI
vim.opt.termguicolors = true

-- Use 4 spaces for tabs
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Enables virtualedit in visual block mode
vim.opt.virtualedit = "block"

-- Use treesitter for folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-- Enable spell checking
-- vim.opt.spelllang = 'es,en,ca'
-- vim.opt.spell = true
