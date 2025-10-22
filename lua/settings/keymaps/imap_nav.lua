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

---

-- -- show `DiagnosticShowFloatWindow`
-- vim.api.nvim_set_keymap("i", "<C-S-k>",
--     "<cmd>DiagnosticShowFloatWindow<CR>",
-- {
--     desc = "show floating window diagnostic",
--     silent = true,
--     noremap = true
-- })

---
---

-- -- go to definition
-- -- TODO: need to store where it come from first so it can go bacl
-- vim.keymap.set("i", "<S-j>",
--     vim.lsp.buf.definition,
-- {
--     desc = "go to definition",
--     silent = true,
--     noremap = true
-- })

