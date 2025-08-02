-- navigate buffer left
vim.api.nvim_set_keymap("n", "<C-A-Left>",
    "<C-w>h",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
-- navigate buffer right
vim.api.nvim_set_keymap("n", "<C-A-Right>",
    "<C-w>l",
{
    desc = "navigate buf left",
    silent = true,
    noremap = true
})
-- navigate buffer up
vim.api.nvim_set_keymap("n", "<C-A-Up>",
    "<C-w>k",
{
    desc = "navigate buf up",
    silent = true,
    noremap = true
})
-- navigate buffer down
vim.api.nvim_set_keymap("n", "<C-A-Down>",
    "<C-w>j",
{
    desc = "navigate buf down",
    silent = true,
    noremap = true
})
