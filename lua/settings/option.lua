vim.opt.updatetime = 150
vim.opt.timeoutlen = 300

vim.opt.showmode = false
vim.opt.splitkeep = "screen"
vim.opt.laststatus = 12

vim.opt.number = true
vim.opt.termguicolors = true

vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.softtabstop = 4

vim.opt.fillchars = { eob = " " }
-- vim.opt.shortmess:append "sI" -- greeter
vim.opt.whichwrap:append "<>[]hl"

vim.opt.winborder = "rounded"

-- ensure is split right when press `v` in netrw
vim.opt.splitright = true

-- custom clipboard
--- yank will consistent in insert and normal mode
vim.opt.clipboard = "unnamedplus"
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 'X', '"_X', { noremap = true })
vim.keymap.set('n', 'gp', '"0p')
vim.keymap.set('n', 'gP', '"0p')
vim.keymap.set('v', 'gp', '"0p')
