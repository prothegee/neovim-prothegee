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
--]]
vim.cmd [[
    "base theme
    colorscheme retrobox

    highlight Normal guibg=none
    highlight NonText guibg=none
    highlight Normal ctermbg=none
    highlight NonText ctermbg=none

    highlight VertSplit guibg=none
    highlight SignColumn guibg=none
]]

---

-- status line
-- * see settings/global.lua for lua.* global functions
vim.opt.statusline = "  %{v:lua.get_active_current_mode()}   %f %m %=  %{v:lua.get_active_lsp()} 󱪶 %l:󱪷 %c  󱗖 %p%% "
