local _nvim_tree_api = require "nvim-tree.api"

-- open/focus tree explorer
vim.keymap.set(
    "n", "<C-S-e>",
    function()
        local tree = _nvim_tree_api.tree

        if tree.is_visible() then
            tree.focus()
        else
            tree.toggle()
        end
    end,
    {
        desc = "File Explorer: toggle file explorer",
        noremap = true,
        silent = true
    }
)
-- close tree explorer
vim.keymap.set(
    "n", "<C-S-x>",
    function()
        local tree = _nvim_tree_api.tree

        if tree.is_visible() then
            tree.close()
        end
    end,
    {
        desc = "File Explorer: toggle file explorer",
        noremap = true,
        silent = true
    }
)
