local bg = "none"
local bg_surface = "#efefef"
local bg_visual = "#f7f6c8"
local bg_status_line = "#f4f4f4"
local bg_search = "#fcfc6a"
local bg_match_paren = "#f4cca1"
local bg_diff_line = "#e8e8fc"
local bg_diff_text = "#d4d4fc"

local fg = "#333333"
local fg_info = "#2563EB"
local fg_success = "#03770d"
local fg_warn = "#938c02"
local fg_comment = "#b0b0b0"
local fg_function = "#1504a5"
local fg_string = "#03770d"
local fg_number = "#009999"
local fg_type = "#990000"
local fg_error = "#dd0808"
local fg_git_conflict = "#9203b2"

vim.api.nvim_command("let g:colors_name = 'light'")

vim.o.background = "light"

vim.api.nvim_set_hl(0, "Normal", {fg = fg, bg = bg})

-- Programming languages
vim.api.nvim_set_hl(0, "@variable", {fg = fg})
vim.api.nvim_set_hl(0, "@keyword", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "@function.call", {fg = fg_function, bold = true})
vim.api.nvim_set_hl(0, "@boolean", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "@number", {fg = fg_number})
vim.api.nvim_set_hl(0, "@markup.italic", {fg = fg})
vim.api.nvim_set_hl(0, "String", {fg = fg_string})
vim.api.nvim_set_hl(0, "Operator", {fg = fg})
vim.api.nvim_set_hl(0, "Delimiter", {fg = fg})
vim.api.nvim_set_hl(0, "Function", {fg = fg_function, bold = true})
vim.api.nvim_set_hl(0, "Identifier", {fg = fg})
vim.api.nvim_set_hl(0, "Type", {fg = fg_type, bold = true})
vim.api.nvim_set_hl(0, "Constant", {fg = fg})

-- Common
vim.api.nvim_set_hl(0, "Special", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "Title", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "DiagnosticInfo", {fg = fg_info, bold = true})
vim.api.nvim_set_hl(0, "DiagnosticError", {fg = fg_error, bold = true})
vim.api.nvim_set_hl(0, "DiagnosticWarn", {fg = fg_warn, bold = true})
vim.api.nvim_set_hl(0, "DiagnosticHint", {fg = fg_info, bold = true})
vim.api.nvim_set_hl(0, "DiagnosticOk", {fg = fg_success, bold = true})
vim.api.nvim_set_hl(0, "Statement", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "Directory", {fg = fg})
vim.api.nvim_set_hl(0, "Visual", {fg = fg, bg = bg_visual})
vim.api.nvim_set_hl(0, "VisualNC", {fg = fg, bg = bg_visual})
vim.api.nvim_set_hl(0, "StatusLine", {fg = fg, bg = bg_status_line})
vim.api.nvim_set_hl(0, "StatusLineNC", {fg = fg, bg = bg_status_line})
vim.api.nvim_set_hl(0, "Error", {fg = fg_error})
vim.api.nvim_set_hl(0, "ErrorMsg", {fg = fg_error})
vim.api.nvim_set_hl(0, "NormalFloat", {fg = fg, bg = bg})
vim.api.nvim_set_hl(0, "CursorLine", {fg = fg, bg = bg_surface})
vim.api.nvim_set_hl(0, "TermCursor", {fg = fg})
vim.api.nvim_set_hl(0, "Search", {fg = fg, bg = bg_search})
vim.api.nvim_set_hl(0, "IncSearch", {fg = fg, bg = bg_search})
vim.api.nvim_set_hl(0, "CurSearch", {fg = fg, bg = bg_search})
vim.api.nvim_set_hl(0, "MoreMsg", {fg = fg})
vim.api.nvim_set_hl(0, "ModeMsg", {fg = fg_success})
vim.api.nvim_set_hl(0, "Question", {fg = fg})
vim.api.nvim_set_hl(0, "PreProc", {fg = fg})
vim.api.nvim_set_hl(0, "Pmenu", {fg = fg})
vim.api.nvim_set_hl(0, "PmenuKind", {fg = fg})
vim.api.nvim_set_hl(0, "PmenuExtra", {fg = fg})
vim.api.nvim_set_hl(0, "PmenuSbar", {fg = fg})
vim.api.nvim_set_hl(0, "PmenuThumb", {fg = fg})
vim.api.nvim_set_hl(0, "Cursor", {fg = fg})
vim.api.nvim_set_hl(0, "CursorColumn", {fg = fg})
vim.api.nvim_set_hl(0, "ColorColumn", {fg = fg})
vim.api.nvim_set_hl(0, "CursorIM", {fg = fg})
vim.api.nvim_set_hl(0, "lCursor", {fg = fg})
vim.api.nvim_set_hl(0, "MatchParen", {fg = fg, bg = bg_match_paren})
vim.api.nvim_set_hl(0, "Comment", {fg = fg_comment})
vim.api.nvim_set_hl(0, "DiffAdd", {fg = fg_success})
vim.api.nvim_set_hl(0, "DiffChange", {fg = fg, bg = bg_diff_line})
vim.api.nvim_set_hl(0, "DiffText", {fg = fg, bg = bg_diff_text})
vim.api.nvim_set_hl(0, "DiffDelete", {fg = fg_error})
vim.api.nvim_set_hl(0, "WinBar", {fg = fg})
vim.api.nvim_set_hl(0, "WinBarNC", {fg = fg})
vim.api.nvim_set_hl(0, "RedrawDebugNormal", {fg = fg})
vim.api.nvim_set_hl(0, "Folded", {fg = fg, bg = bg_surface})
vim.api.nvim_set_hl(0, "WildMenu", {fg = fg, bg = bg_surface})
vim.api.nvim_set_hl(0, "QuickFixLine", {fg = fg, bg = bg_surface})
vim.api.nvim_set_hl(0, "Added", {fg = fg_success})
vim.api.nvim_set_hl(0, "Removed", {fg = fg_error})
vim.api.nvim_set_hl(0, "Changed", {fg = fg_info})
vim.api.nvim_set_hl(0, "NeoTreeTitleBar", {fg = fg, bold = true})
vim.api.nvim_set_hl(0, "NeoTreeGitConflict", {fg = fg_git_conflict})

