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
    "colorscheme wildcharm
    colorscheme slate
    "colorscheme vaporwave

    augroup TransparentGrp
        autocmd!
        " "remove background
        autocmd ColorScheme * highlight Normal          guibg=none      guifg=none
        autocmd Colorscheme * highlight NormalNC        guibg=none      guifg=none
        autocmd ColorScheme * highlight NormalFloat     guibg=none      guifg=#afaf87
        autocmd ColorScheme * highlight FloatBorder     guibg=none      guifg=#afaf87
        autocmd ColorScheme * highlight NonText         guibg=none      guifg=none
        autocmd ColorScheme * highlight SignColumn      guibg=none      guifg=none
        autocmd ColorScheme * highlight VertSplit       guibg=none      guifg=#afaf87

        " "match bracket
        autocmd ColorScheme * highlight MatchParen      guibg=#484848   guifg=#afaf87
        "autocmd ColorScheme * highlight MatchParen      guibg=#afaf87   guifg=#484848

        " "status line
        autocmd ColorScheme * highlight StatusLine      guibg=#afaf87   guifg=#121212
        autocmd ColorScheme * highlight StatusLineNC    guibg=#272727   guifg=#afaf87

        " "window floating
        autocmd ColorScheme * highlight PMenu           guibg=#333327
    augroup END

    "colorscheme wildcharm
    colorscheme slate
    "colorscheme vaporwave
]])

---

-- status line
-- * see settings/global.lua for lua.* global functions
-- vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %f %m %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "
vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %{v:lua.get_cwd_and_file_buffer()} %=  %{v:lua.get_active_lsp()}  %{v:lua.get_diagnostic_hint()}  %{v:lua.get_diagnostic_info()}  %{v:lua.get_diagnostic_warn()}  %{v:lua.get_diagnostic_error()}  󱪶 %l:󱪷 %c  󱗖 %p%% "

