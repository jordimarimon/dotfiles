-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.o.number = true

-- Set line numbers to be relative
vim.o.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Add support for hyperlinks
vim.o.conceallevel = 2

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  See `:help 'clipboard'`
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

-- Signcolumn of 5 columnwidth with signs
vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%l%s" -- number sign

-- Don't have `o` add a comment
vim.opt.formatoptions:remove({ "o", "r" })

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 500

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Set completeopt to have a better completion experience
vim.o.completeopt = "fuzzy,menuone,noselect"

-- Enables 24-bit RGB color in the TUI
vim.o.termguicolors = true

-- Use 4 spaces for tabs
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Enables virtualedit in visual block mode
vim.o.virtualedit = "block"

-- Make sure fold is disabled by default
vim.o.foldenable = false
vim.o.foldlevel = 99
vim.o.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })

-- Spell checking
-- https://github.com/vim/vim/tree/master/runtime/spell
-- To make spelling work, use vim instead of neovim because
-- for some reason neovim doesn't prompt for download
vim.o.spelllang = "es,en,ca"
vim.o.spell = false
vim.o.spelloptions = "camel,noplainbuffer"

-- Command height
vim.o.cmdheight = 1

-- Better diff
vim.o.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"

-- Improve quickfix/loclist display
_G.quickfix_entries_text = require("custom.quickfix").create_entries
vim.o.quickfixtextfunc = "v:lua.quickfix_entries_text"

-- Set border for floating windows
vim.o.winborder = "single"

-- More intuitive adding and subtracting
vim.o.nrformats = "unsigned"

-- Disable modeline
vim.o.modeline = false
