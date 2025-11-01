local function create_empty_new_tab()
    vim.cmd("tabnew")
end

---

-- open new tab
-- mode:
-- - normal
-- - insert
-- - visual
-- - terminal
vim.keymap.set(
    { "n", "i", "v", "t" },
    "<C-S-A-t>",
    create_empty_new_tab,
    {
        desc = "create empty new tab (mode: n, i, v, t)"
    }
)

