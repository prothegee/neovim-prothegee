vim.api.nvim_set_keymap(
    "i", "{",
    "{}<left>",
    {
        noremap = true,
        silent = true
    }
)
vim.api.nvim_set_keymap(
    "i", "[",
    "[]<left>",
    {
        noremap = true,
        silent = true
    }
)
vim.api.nvim_set_keymap(
    "i", "(",
    "()<left>",
    {
        noremap = true,
        silent = true
    }
)
vim.api.nvim_set_keymap(
    "i", "<",
    "<><left>",
    {
        noremap = true,
        silent = true
    }
)
-- vim.api.nvim_set_keymap(
--     "i", "'",
--     "''<left>",
--     {
--         noremap = true,
--         silent = true
--     }
-- )
-- vim.api.nvim_set_keymap(
--     'i', '"',
--     '""<left>',
--     {
--         noremap = true,
--         silent = true
--     }
-- )
