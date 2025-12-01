--[[
# below list is ok with transparent background
* suits me:
- retrobox
- wildcharm

* kinda ok
- unokai

* not sure but fine
- darkblue
- delek
- desert
- habamax
- koehler
- lunaperche
- pablo
- slate
- sorbet
- torte
- vim

* extra
https://github.com/olimorris/onedarkpro.nvim
- onedark
- onelight
- onedark_vivid
- onedark_dark
- vaporwave
--]]
vim.cmd([[
    " "note:
    " " - gold (bright): #FFBB00
    " " - gold (calm)  : #DFA600

    augroup TransparentGrp
       autocmd!
        autocmd ColorScheme * highlight Normal        guibg=none guifg=none
        autocmd ColorScheme * highlight NormalNC      guibg=none guifg=none
        autocmd ColorScheme * highlight NormalFloat   guibg=none guifg=#DFA600
        autocmd ColorScheme * highlight FloatBorder   guibg=none guifg=#DFA600
        autocmd ColorScheme * highlight NonText       guibg=none guifg=none
        autocmd ColorScheme * highlight SignColumn    guibg=none guifg=none
        autocmd ColorScheme * highlight VertSplit     guibg=none guifg=#DFA600
        autocmd ColorScheme * highlight StatusLine    guibg=#DFA600 guifg=#121212
        autocmd ColorScheme * highlight StatusLineNC  guibg=#272727 guifg=#DFA600
            "autocmd ColorScheme * highlight TabLine       guibg=none guifg=none
            "autocmd ColorScheme * highlight TabLineSel    guibg=none guifg=none
            "autocmd ColorScheme * highlight TabLineFill   guibg=none guifg=none
        autocmd ColorScheme * highlight WinSeparator  guibg=none guifg=#DFA600
            "autocmd ColorScheme * highlight Folded        guibg=none guifg=none
            "autocmd ColorScheme * highlight FoldColumn    guibg=none guifg=none
        autocmd ColorScheme * highlight CursorLine    guibg=#DFA600 guifg=#121212
            "autocmd ColorScheme * highlight CursorColumn  guibg=none guifg=none
            "autocmd ColorScheme * highlight ColorColumn   guibg=none guifg=none
        autocmd ColorScheme * highlight LineNr        guibg=none guifg=#DFA600
            "autocmd ColorScheme * highlight CursorLineNr  guibg=none guifg=none
            "autocmd ColorScheme * highlight EndOfBuffer   guibg=none guifg=none
        autocmd ColorScheme * highlight Pmenu         guibg=#121212 guifg=#DFA600
        autocmd ColorScheme * highlight PmenuSel      guibg=#DFA600 guifg=#121212
            "autocmd ColorScheme * highlight PmenuSbar     guibg=none guifg=none
            "autocmd ColorScheme * highlight PmenuThumb    guibg=none guifg=none
            "autocmd ColorScheme * highlight WildMenu      guibg=none guifg=none
            "autocmd ColorScheme * highlight Search        guibg=none guifg=none
            "autocmd ColorScheme * highlight IncSearch     guibg=none guifg=none
        autocmd ColorScheme * highlight Visual        guibg=#DFA600 guifg=#121212
            "autocmd ColorScheme * highlight VisualNOS     guibg=none guifg=none
        autocmd ColorScheme * highlight MatchParen    guibg=none guifg=none
            "autocmd ColorScheme * highlight Question      guibg=none guifg=none
            "autocmd ColorScheme * highlight MoreMsg       guibg=none guifg=none
            "autocmd ColorScheme * highlight ModeMsg       guibg=none guifg=none
            "autocmd ColorScheme * highlight ErrorMsg      guibg=none guifg=none
            "autocmd ColorScheme * highlight WarningMsg    guibg=none guifg=none
            "autocmd ColorScheme * highlight Title         guibg=none guifg=none
            "autocmd ColorScheme * highlight Directory     guibg=none guifg=none
            "autocmd ColorScheme * highlight Comment       guibg=none guifg=none
            "autocmd ColorScheme * highlight Constant      guibg=none guifg=none
            "autocmd ColorScheme * highlight Special       guibg=none guifg=none
            "autocmd ColorScheme * highlight Identifier    guibg=none guifg=none
            "autocmd ColorScheme * highlight Statement     guibg=none guifg=none
            "autocmd ColorScheme * highlight PreProc       guibg=none guifg=none
            "autocmd ColorScheme * highlight Type          guibg=none guifg=none
            "autocmd ColorScheme * highlight Underlined    guibg=none guifg=none
            "autocmd ColorScheme * highlight Ignore        guibg=none guifg=none
            "autocmd ColorScheme * highlight Error         guibg=none guifg=none
            "autocmd ColorScheme * highlight Todo          guibg=none guifg=none
            "autocmd ColorScheme * highlight SpellBad      guibg=none guifg=none
            "autocmd ColorScheme * highlight SpellCap      guibg=none guifg=none
            "autocmd ColorScheme * highlight SpellRare     guibg=none guifg=none
            "autocmd ColorScheme * highlight SpellLocal    guibg=none guifg=none
            "autocmd ColorScheme * highlight Whitespace    guibg=none guifg=none
            "autocmd ColorScheme * highlight TermCursor    guibg=none guifg=none
            "autocmd ColorScheme * highlight TermCursorNC  guibg=none guifg=none
            "autocmd ColorScheme * highlight WinBar        guibg=none guifg=none
            "autocmd ColorScheme * highlight WinBarNC      guibg=none guifg=none
            "autocmd ColorScheme * highlight MsgArea       guibg=none guifg=none
            "autocmd ColorScheme * highlight MsgSeparator  guibg=none guifg=none

        "" pmenu
            autocmd ColorScheme * highlight Pmenu       guibg=none guifg=#DFA600
            autocmd ColorScheme * highlight PmenuSel    guibg=#DFA600 guifg=#121212
            autocmd ColorScheme * highlight PmenuBorder guibg=#121212 guifg=#DFA600
            autocmd ColorScheme * highlight PmenuSbar   guibg=#121212 guifg=#DFA600
            autocmd ColorScheme * highlight PmenuThumb  guibg=#DFA600 guifg=#121212

        "" diagnostic
            "autocmd ColorScheme * highlight DiagnosticError           guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticWarn            guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticInfo            guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticHint            guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticUnderlineError  guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticUnderlineWarn   guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticUnderlineInfo   guibg=none guifg=none
            "autocmd ColorScheme * highlight DiagnosticUnderlineHint   guibg=none guifg=none
        
        "" lsp
            "autocmd ColorScheme * highlight LspReferenceText          guibg=none guifg=none
            "autocmd ColorScheme * highlight LspReferenceRead          guibg=none guifg=none
            "autocmd ColorScheme * highlight LspReferenceWrite         guibg=none guifg=none

        "" completion
            autocmd ColorScheme * highlight CmpItemAbbr           guibg=none guifg=none
            autocmd ColorScheme * highlight CmpItemAbbrDeprecated guibg=none guifg=none
            autocmd ColorScheme * highlight CmpItemAbbrMatch      guibg=none guifg=none
            autocmd ColorScheme * highlight CmpItemAbbrMatchFuzzy guibg=none guifg=none
            autocmd ColorScheme * highlight CmpItemKind           guibg=none guifg=none
            autocmd ColorScheme * highlight CmpItemMenu           guibg=none guifg=none
    augroup END

    colorscheme onedark
]])

---

-- status line
-- * see settings/global.lua for lua.* global functions
-- vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %f %m %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "
vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_cwd_and_file_buffer()} %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "

