local _xplrr = require"nvim-prt.xplrr"
print("shouldn't loaded")
vim.api.nvim_create_user_command(_xplrr.cmd.xplrr_files, _xplrr.toggle_files, {})
vim.api.nvim_create_user_command(_xplrr.cmd.xplrr_buffers, _xplrr.toggle_buffers, {})
