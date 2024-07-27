" vim: set foldmethod=marker foldlevel=1 :

hi clear
if exists("syntax_on")
    syntax reset
endif

let colors_name = "light"

" Helper functions {{{
" from vim-gotham

function! s:Highlight(args)
  exec 'highlight ' . join(a:args, ' ')
endfunction

function! s:AddGroundValues(accumulator, ground, color)
  let new_list = a:accumulator
  for [where, value] in items(a:color)
    call add(new_list, where . a:ground . '=' . value)
  endfor

  return new_list
endfunction

function! s:Col(group, fg_name, ...)
  " ... = optional bg_name

  let pieces = [a:group]

  if a:fg_name !=# ''
    let pieces = s:AddGroundValues(pieces, 'fg', s:colors[a:fg_name])
  endif

  if a:0 > 0 && a:1 !=# ''
    let pieces = s:AddGroundValues(pieces, 'bg', s:colors[a:1])
  endif

  call s:Clear(a:group)
  call s:Highlight(pieces)
endfunction

function! s:Attr(group, attr)
  let l:attrs = [a:group, 'term=' . a:attr, 'cterm=' . a:attr, 'gui=' . a:attr]
  call s:Highlight(l:attrs)
endfunction

function! s:Spell(group, attr)
  let l:attrs = [a:group, 'guisp=' . s:colors[a:attr].gui ]
  call s:Highlight(l:attrs)
endfunction


function! s:Clear(group)
  exec 'highlight clear ' . a:group
endfunction

" }}}
" }}}

" Colors {{{

let s:lib = {}
let s:lib.numDarkest = { 'gui': '#76787b', 'cterm': 243 }
let s:lib.numMedium  = { 'gui': '#979797', 'cterm': 246 }
let s:lib.numLighter = { 'gui': '#babbbc', 'cterm': 250 }
let s:lib.c8d1db     = { 'gui': '#C8D1DB', 'cterm': 252 }
let s:lib.d7dce1     = { 'gui': '#d7dce1', 'cterm': 253 }
let s:lib.dde2e7     = { 'gui': '#C8CED6', 'cterm': 254 }
let s:lib.e0e7ef     = { 'gui': '#e0e7ef', 'cterm': 254 }
let s:lib.ebeced     = { 'gui': '#ebeced', 'cterm': 255 }
let s:lib.eceef1     = { 'gui': '#ECEEF1', 'cterm': 255 }
let s:lib.eaeff4     = { 'gui': '#eaeff4', 'cterm': 255 }
let s:lib.f1f2f3     = { 'gui': '#f1f2f4', 'cterm': 255 }
let s:lib.f6f8fa     = { 'gui': '#f6f8fa', 'cterm': 255 }
let s:lib.fafbfc     = { 'gui': '#fafbfc', 'cterm': 255 }
let s:lib.white      = { 'gui': '#ffffff', 'cterm': 231 }
let s:lib.base0      = { 'gui': '#24292e', 'cterm': 235 }
let s:lib.base05     = { 'gui': '#2b3137', 'cterm': 238 }
let s:lib.base05     = { 'gui': '#2d343a', 'cterm': 238 }
let s:lib.base1      = { 'gui': '#41484f', 'cterm': 238 }
let s:lib.base2      = { 'gui': '#6a737d', 'cterm': 243 }
let s:lib.base3      = s:lib.numDarkest

let s:colors = {}
let s:colors.red            = { 'gui': '#d73a49', 'cterm': 167 }
let s:colors.darkred        = { 'gui': '#b31d28', 'cterm': 124 }
let s:colors.purple         = { 'gui': '#6f42c1', 'cterm': 91  }
let s:colors.darkpurple     = { 'gui': '#45267d', 'cterm': 237 }
let s:colors.yellow         = { 'gui': '#ffffc5', 'cterm': 230 }
let s:colors.green          = { 'gui': '#22863a', 'cterm': 29  }
let s:colors.boldgreen      = { 'gui': '#3ebc5c', 'cterm': 29  }
let s:colors.orange         = { 'gui': '#e36209', 'cterm': 166 }
let s:colors.boldorange     = { 'gui': '#f18338', 'cterm': 166 }
let s:colors.lightgreen_nr  = { 'gui': '#cdffd8', 'cterm': 85  }
let s:colors.lightgreen     = { 'gui': '#e6ffed', 'cterm': 85  }
let s:colors.lightred_nr    = { 'gui': '#ffdce0', 'cterm': 167 }
let s:colors.lightred       = { 'gui': '#ffeef0', 'cterm': 167 }
let s:colors.lightorange_nr = { 'gui': '#fff5b1', 'cterm': 229 }
let s:colors.lightorange    = { 'gui': '#fffbdd', 'cterm': 230 }
let s:colors.difftext       = { 'gui': '#f2e496', 'cterm': 222 }
let s:colors.darkblue       = { 'gui': '#032f62', 'cterm': 17  }
let s:colors.blue           = { 'gui': '#005cc5', 'cterm': 26  }
let s:colors.blue0          = { 'gui': '#669cc2', 'cterm': 153 }
let s:colors.blue1          = { 'gui': '#c1daec', 'cterm': 153 }
let s:colors.blue2          = { 'gui': '#e4effb', 'cterm': 153 }
let s:colors.blue3          = { 'gui': '#bde0fb', 'cterm': 153 }
let s:colors.blue4          = { 'gui': '#f1f8ff', 'cterm': 153 }
let s:colors.errorred       = { 'gui': '#b74951', 'cterm': 167 }

" }}}

let s:colors.base0          = s:lib.base0
let s:colors.base1          = s:lib.base1
let s:colors.base2          = s:lib.base2
let s:colors.base3          = s:lib.base3
let s:colors.fg             = s:colors.base0
let s:colors.gutterfg       = s:colors.base3
let s:colors.grey0          = s:lib.dde2e7
let s:colors.grey1          = s:lib.eceef1
let s:colors.grey2          = s:lib.f6f8fa
let s:colors.overlay        = s:lib.f6f8fa
let s:colors.gutter         = s:lib.white
let s:colors.endofbuf       = s:colors.gutter " same
let s:colors.bg             = s:lib.white
let s:colors.base4          = s:lib.numLighter
let s:colors.visualblue     = s:colors.blue2
let s:colors.lightblue      = s:colors.blue4
let s:colors.uisplit        = s:colors.grey1

" named groups to link to {{{
call s:Col('ghBackground', 'bg')
call s:Col('ghBlack', 'base0')
call s:Col('ghBase0', 'base0')
call s:Col('ghBase1', 'base1')
call s:Col('ghBase2', 'base2')
call s:Col('ghBase3', 'base3')
call s:Col('ghBase4', 'base4')
call s:Col('ghGrey0', 'grey0')
call s:Col('ghGrey1', 'grey1')
call s:Col('ghGrey2', 'grey2')
call s:Col('ghGreen', 'green')
call s:Col('ghBlue', 'blue')
call s:Col('ghBlue2', 'blue2')
call s:Col('ghBlue3', 'blue3')
call s:Col('ghBlue4', 'blue4')
call s:Col('ghDarkBlue', 'darkblue')
call s:Col('ghRed', 'red')
call s:Col('ghDarkRed', 'darkred')
call s:Col('ghPurple', 'purple')
call s:Col('ghDarkPurple', 'darkpurple')
call s:Col('ghOrange', 'orange')
call s:Col('ghLightOrange', 'lightorange')
call s:Col('ghYellow', 'yellow')
call s:Col('ghLightRed', 'lightred')
call s:Col('ghOver', 'overlay')
call s:Col('ghUISplit', 'uisplit')
" }}}

" }}}

" UI colors {{{

call s:Col('Normal', 'fg', 'bg')
call s:Col('Cursor', 'bg', 'fg')
call s:Col('Visual', '', 'visualblue')
call s:Col('VisualNOS', '', 'lightblue')
call s:Col('Search', '', 'yellow') | call s:Attr('Search', 'bold')
call s:Col('Whitespace', 'base4', 'bg')
call s:Col('NonText',    'base4', 'bg')
call s:Col('SpecialKey', 'base4', 'bg')
call s:Col('Conceal',    'red')

call s:Col('MatchParen', 'darkblue', 'blue3')
call s:Col('WarningMsg', 'orange')
call s:Col('ErrorMsg', 'errorred')
call s:Col('Error', 'gutterfg', 'errorred')
call s:Col('Title', 'base1')
call s:Attr('Title', 'bold')

call s:Col('VertSplit',    'uisplit', 'uisplit')
call s:Col('LineNr',       'base4',  'gutter')
hi! link     SignColumn       LineNr
call s:Col('EndOfBuffer',  'base4',  'endofbuf')
call s:Col('ColorColumn',  '',       'grey2')

call s:Col('CursorLineNR', 'gutterfg',  'lightorange_nr')
call s:Col('CursorLine',   '',       'lightorange')
call s:Col('CursorColumn', '',       'lightorange')

call s:Col('QuickFixLine', '', 'blue3') | call s:Attr('QuickFixLine', 'bold')
call s:Col('qfLineNr', 'gutterfg', 'gutter')

call s:Col('Folded',     'gutterfg', 'lightblue')
call s:Col('FoldColumn', 'blue0', 'gutter')

call s:Col('StatusLine',      'grey2', 'base0')
call s:Col('StatusLineNC',    'gutterfg', 'grey1')
call s:Col('WildMenu', 'grey2', 'blue')

call s:Col('airlineN1',       'grey1', 'base0')
call s:Col('airlineN2',       'grey1', 'base1')
call s:Col('airlineN3',       'base0',  'grey1')
call s:Col('airlineInsert1',  'grey1', 'blue')
call s:Col('airlineInsert2',  'grey1', 'darkblue')
call s:Col('airlineVisual1',  'grey1', 'purple')
call s:Col('airlineVisual2',  'grey1', 'darkpurple')
call s:Col('airlineReplace1', 'grey1', 'red')
call s:Col('airlineReplace2', 'grey1', 'darkred')

call s:Col('Pmenu',      'base3', 'overlay')
call s:Col('PmenuSel',   'overlay',  'blue') | call s:Attr('PmenuSel', 'bold')
call s:Col('PmenuSbar',  '',      'grey2')
call s:Col('PmenuThumb', '',      'grey0')


" hit enter to continue
call s:Col('Question', 'green')

call s:Col('TabLine',     'base1', 'grey1') | call s:Attr('TabLine', 'none')
call s:Col('TabLineFill', 'base0', 'base0') | call s:Attr('TabLineFill', 'none')
call s:Col('TabLineFill', 'grey0', 'grey0') | call s:Attr('TabLineFill', 'none')
call s:Col('TabLineSel',  'base1'         ) | call s:Attr('TabLineSel', 'bold')

call s:Col('DiffAdd',    '', 'lightgreen')
call s:Col('DiffDelete', 'base4', 'lightred') | call s:Attr('DiffDelete', 'none')
call s:Col('DiffChange', '', 'lightorange')
call s:Col('DiffText',   '', 'difftext')

" }}}

" {{{ Syntax highlighting

call s:Clear('Ignore') | call s:Col('Ignore', 'base4', 'bg')
call s:Col('Identifier', 'blue')
call s:Col('PreProc', 'red')
call s:Col('Macro', 'blue')
call s:Col('Define', 'purple')
call s:Col('Comment', 'base2')
call s:Col('Constant', 'blue')
call s:Col('String', 'darkblue')
call s:Col('Function', 'purple')
call s:Col('Statement', 'red')
call s:Col('Type', 'red')
call s:Col('Todo', 'purple') | call s:Attr('Todo', 'underline')
call s:Col('Special', 'purple')
call s:Col('SpecialComment', 'base0')
call s:Col('Label', 'base0')
call s:Col('StorageClass', 'red')
call s:Col('Structure', 'red')

