-- delete backspace
vim.api.nvim_set_keymap(
    "i", "<C-BS>",
    "<C-W>",
    {
        desc = "delete backward",
        noremap = true,
        silent = true
    }
)
