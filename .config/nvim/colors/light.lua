local bg = "none"
local bg_surface = "#efefef"
local bg_light_blue = "#dbeafe"
local bg_tab_sel = "#FFFFFF"
local bg_visual = "#f7f6c8"
local bg_status_line = "#040299"
local bg_search = "#fcfc6a"
local bg_match_paren = "#f4cca1"
local bg_diff_line = "none"
local bg_diff_text = "#d4d4fc"
local bg_diff_add = "#d4ffdf"
local bg_diff_delete = "#ffd8d4"
local bg_context = "#eff6ff"
local bg_mark = "#115E59"
local bg_status_line_mode = "#d4d4fc"
local bg_heading_1_markdown = "#dbeafe"
local bg_heading_2_markdown = "#ffedd5"
local bg_heading_3_markdown = "#fef3c7"
local bg_heading_4_markdown = "#ecfccb"
local bg_heading_5_markdown = "#ccfbf1"

local fg = "#000000"
local fg_status_line = "#FFFFFF"
local fg_info = "#2563EB"
local fg_success = "#03770d"
local fg_mark = "#FFFFFF"
local fg_warn = "#938c02"
local fg_comment = "#b0b0b0"
local fg_function = "#1504a5"
local fg_ts_uvar = "#1504a5"
local fg_string = "#03770d"
local fg_number = "#009999"
local fg_type = "#690363"
local fg_error = "#dd0808"
local fg_tag = "#78716c"
local fg_member = "#000000"

vim.g.colors_name = "light"
vim.o.background = "light"

-- Common
vim.api.nvim_set_hl(0, "Normal", { fg = fg, bg = bg })
vim.api.nvim_set_hl(0, "Title", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = fg_info, bold = true })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = fg_error, bold = true })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = fg_warn, bold = true })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = fg_info, bold = true })
vim.api.nvim_set_hl(0, "DiagnosticOk", { fg = fg_success, bold = true })
vim.api.nvim_set_hl(0, "Statement", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "Directory", { fg = fg })
vim.api.nvim_set_hl(0, "Visual", { bg = bg_visual })
vim.api.nvim_set_hl(0, "VisualNC", { bg = bg_visual })
vim.api.nvim_set_hl(0, "StatusLine", { fg = fg_status_line, bg = bg_status_line })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = fg_status_line, bg = bg_status_line })
vim.api.nvim_set_hl(0, "TabLine", { fg = fg_status_line, bg = bg_status_line })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = fg, bg = bg_tab_sel })
vim.api.nvim_set_hl(0, "Error", { fg = fg_error })
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = fg_error })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg, bg = bg })
vim.api.nvim_set_hl(0, "CursorLine", { bg = bg_surface })
vim.api.nvim_set_hl(0, "TermCursor", { fg = fg, bg = fg })
vim.api.nvim_set_hl(0, "Search", { fg = fg, bg = bg_search })
vim.api.nvim_set_hl(0, "IncSearch", { fg = fg, bg = bg_search })
vim.api.nvim_set_hl(0, "CurSearch", { fg = fg, bg = bg_search })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = fg })
vim.api.nvim_set_hl(0, "ModeMsg", { fg = fg_success })
vim.api.nvim_set_hl(0, "Question", { fg = fg })
vim.api.nvim_set_hl(0, "PreProc", { fg = fg })
vim.api.nvim_set_hl(0, "Pmenu", { fg = fg })
vim.api.nvim_set_hl(0, "PmenuKind", { fg = fg })
vim.api.nvim_set_hl(0, "PmenuExtra", { fg = fg })
vim.api.nvim_set_hl(0, "PmenuSbar", { fg = fg })
vim.api.nvim_set_hl(0, "PmenuThumb", { fg = fg })
vim.api.nvim_set_hl(0, "Cursor", { fg = fg })
vim.api.nvim_set_hl(0, "CursorColumn", { fg = fg })
vim.api.nvim_set_hl(0, "ColorColumn", { fg = fg })
vim.api.nvim_set_hl(0, "CursorIM", { fg = fg })
vim.api.nvim_set_hl(0, "lCursor", { fg = fg })
vim.api.nvim_set_hl(0, "MatchParen", { fg = fg, bg = bg_match_paren })
vim.api.nvim_set_hl(0, "Comment", { fg = fg_comment })
vim.api.nvim_set_hl(0, "DiffAdd", { bg = bg_diff_add })
vim.api.nvim_set_hl(0, "DiffChange", { bg = bg_diff_line })
vim.api.nvim_set_hl(0, "DiffText", { bg = bg_diff_text })
vim.api.nvim_set_hl(0, "DiffDelete", { bg = bg_diff_delete })
vim.api.nvim_set_hl(0, "WinBar", { fg = fg })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = fg })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = fg })
vim.api.nvim_set_hl(0, "RedrawDebugNormal", { fg = fg })
vim.api.nvim_set_hl(0, "Folded", { fg = fg, bg = bg_light_blue })
vim.api.nvim_set_hl(0, "WildMenu", { fg = fg, bg = bg_surface })
vim.api.nvim_set_hl(0, "QuickFixLine", { fg = fg, bg = bg_surface })
vim.api.nvim_set_hl(0, "Added", { fg = fg_success })
vim.api.nvim_set_hl(0, "Removed", { fg = fg_error })
vim.api.nvim_set_hl(0, "Changed", { fg = fg_info })
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = fg_comment })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = fg })
vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = fg })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = fg_warn })
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = bg_context })
vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, underline = true, sp = fg_error })
vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, underline = true, sp = fg_error })
vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, underline = true, sp = fg_error })
vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, underline = true, sp = fg_error })
vim.api.nvim_set_hl(
    0,
    "DiagnosticUnderlineError",
    { undercurl = true, underline = true, sp = fg_error }
)
vim.api.nvim_set_hl(
    0,
    "DiagnosticUnderlineWarn",
    { undercurl = true, underline = true, sp = fg_warn }
)
vim.api.nvim_set_hl(
    0,
    "DiagnosticUnderlineInfo",
    { undercurl = true, underline = true, sp = fg_info }
)
vim.api.nvim_set_hl(
    0,
    "DiagnosticUnderlineHint",
    { undercurl = true, underline = true, sp = fg_info }
)
vim.api.nvim_set_hl(
    0,
    "DiagnosticUnderlineOk",
    { undercurl = true, underline = true, sp = fg_success }
)
vim.api.nvim_set_hl(0, "PmenuThumb", { fg = fg, bg = fg })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = bg })
vim.api.nvim_set_hl(0, "qfFilename", { fg = fg })
vim.api.nvim_set_hl(0, "qfText", { fg = fg })
vim.api.nvim_set_hl(0, "qfLineNr", { fg = fg_number })

-- MiniStatusLine
vim.api.nvim_set_hl(0, "MiniStatusLineModeNormal", { fg = fg, bg = bg_status_line_mode })
vim.api.nvim_set_hl(0, "MiniStatusLineModeInsert", { fg = fg, bg = bg_status_line_mode })
vim.api.nvim_set_hl(0, "MiniStatusLineModeVisual", { fg = fg, bg = bg_status_line_mode })
vim.api.nvim_set_hl(0, "MiniStatusLineModeReplace", { fg = fg, bg = bg_status_line_mode })
vim.api.nvim_set_hl(0, "MiniStatusLineModeCommand", { fg = fg, bg = bg_status_line_mode })
vim.api.nvim_set_hl(0, "MiniStatusLineModeOther", { fg = fg, bg = bg_status_line_mode })

-- GitSigns
vim.api.nvim_set_hl(0, "GitSignsAddInline", { fg = fg_success, bg = bg_diff_add })
vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { fg = fg_error, bg = bg_diff_delete })
vim.api.nvim_set_hl(0, "GitSignsChangeInline", { fg = fg, bg = bg_diff_line })

-- Programming languages
vim.api.nvim_set_hl(0, "Special", { bold = true })
vim.api.nvim_set_hl(0, "String", { fg = fg_string })
vim.api.nvim_set_hl(0, "Operator", { fg = fg })
vim.api.nvim_set_hl(0, "Delimiter", { fg = fg })
vim.api.nvim_set_hl(0, "Function", { fg = fg_function, bold = true })
vim.api.nvim_set_hl(0, "Type", { fg = fg_type, bold = true })
vim.api.nvim_set_hl(0, "Constant", { fg = fg })
vim.api.nvim_set_hl(0, "Identifier", { fg = fg })
vim.api.nvim_set_hl(0, "@type", { fg = fg_type, bold = true })
vim.api.nvim_set_hl(0, "@type.builtin", { fg = fg_type, bold = true })
vim.api.nvim_set_hl(0, "@variable", { fg = fg })
vim.api.nvim_set_hl(0, "@variable.member", { fg = fg_member })
vim.api.nvim_set_hl(0, "@variable.builtin", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@constant", { fg = fg })
vim.api.nvim_set_hl(0, "@keyword", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@keyword.conditional.ternary", { fg = fg, bold = false })
vim.api.nvim_set_hl(0, "@function.builtin", { fg = fg_function, bold = true })
vim.api.nvim_set_hl(0, "@function.call", { fg = fg_function, bold = true })
vim.api.nvim_set_hl(0, "@boolean", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@number", { fg = fg_number })
vim.api.nvim_set_hl(0, "@markup.italic", { fg = fg })
vim.api.nvim_set_hl(0, "@tag.attribute", { fg = fg, bold = false })
vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = fg, bold = false })
vim.api.nvim_set_hl(0, "@punctuation.special", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@tag", { fg = fg_tag, bold = true })
vim.api.nvim_set_hl(0, "@tag.builtin", { fg = fg_tag, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.1", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.2", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.3", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.4", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.5", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.heading.6", { fg = fg })
vim.api.nvim_set_hl(0, "@markup.strong", { bold = false })

-- TypeScript
vim.api.nvim_set_hl(0, "@typescript.uppercase_variable", { fg = fg_ts_uvar })

-- Markdown
vim.api.nvim_set_hl(0, "@markup.heading.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "@markup.strong.markdown", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = bg_heading_1_markdown })
vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = bg_heading_2_markdown })
vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = bg_heading_3_markdown })
vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = bg_heading_4_markdown })
vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = fg, bold = true })
vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = bg_heading_5_markdown })
vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = bg })

-- Marks
vim.api.nvim_set_hl(0, "MarkHighlight", { bg = bg_mark, fg = fg_mark })
vim.api.nvim_set_hl(0, "MarkSignHighlight", { fg = bg_mark })
