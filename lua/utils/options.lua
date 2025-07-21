local _g = vim.g
local _o = vim.o
local _wo = vim.wo
local _opt = vim.opt

---

_o.updatetime = 150
_o.timeoutlen = 300

_o.showmode = false
_o.splitkeep = "screen"
_o.laststatus = 6

_o.clipboard = "unnamedplus"

---

_opt.number = true

_opt.termguicolors = true

_opt.tabstop = 4
_opt.expandtab = true
_opt.shiftwidth = 4
_opt.smartindent = true
_opt.softtabstop = 4

_opt.fillchars = { eob = " " }
_opt.shortmess:append "sI"
_opt.whichwrap:append "<>[]hl"

