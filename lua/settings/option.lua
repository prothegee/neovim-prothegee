vim.opt.updatetime = 120
vim.opt.timeoutlen = 240

vim.opt.showmode = false
vim.opt.number = true
vim.opt.relativenumber = true

-- start tab
vim.opt.tabstop = 4
-- vim.opt.expandtab = true
vim.opt.shiftwidth = 4
-- vim.opt.smartindent = true
vim.opt.softtabstop = 4
-- end tab

vim.opt.fillchars = { eob = " " }
-- greeter
-- vim.opt.shortmess::append "sI"
-- vim.opt.whichwrap:append "<>[]hl"

-- rounded single double shadow
vim.opt.winborder = "single"

-- ensure split vertical when press v in netrw
vim.opt.splitright = true

--[[
custom opt clipboard
--]]
vim.opt.clipboard = "unnamedplus"

