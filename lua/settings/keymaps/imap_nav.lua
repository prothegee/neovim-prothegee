-- delete backward
vim.api.nvim_set_keymap("i", "<A-BS>",
    "<C-W>",
{
    desc = "delete backward",
    silent = true,
    noremap = true
})
-- delete forward
vim.api.nvim_set_keymap("i", "<A-Del>",
    "<C-o>dw",
{
    desc = "delete forward",
    silent = true,
    noremap = true
})
