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

---

-- show `DiagnosticShowFloatWindow`
vim.api.nvim_set_keymap("n", "<C-S-k>",
    "<cmd>DiagnosticShowFloatWindow<CR>",
{
    desc = "show floating window diagnostic",
    silent = true,
    noremap = true
})

---
---

-- go to definition
-- TODO: need to store where it come from first so it can go bacl
vim.keymap.set("n", "<S-j>",
    vim.lsp.buf.definition,
{
    desc = "go to definition",
    silent = true,
    noremap = true
})

