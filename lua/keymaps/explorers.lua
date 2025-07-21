local _nvim_tree_api = require "nvim-tree.api"
local _telescope_builtin = require("telescope.builtin")

-- file explorer
--- open/focus tree explorer
vim.keymap.set(
    "n", "<C-A-e>",
    function()
        local tree = _nvim_tree_api.tree

        if tree.is_visible() then
            tree.focus()
        else
            tree.toggle()
        end
    end,
    {
        desc = "File Explorer: toggle file explorer"
    }
)
--- close tree explorer
vim.keymap.set(
    "n", "<C-A-x>",
    function()
        local tree = _nvim_tree_api.tree

        if tree.is_visible() then
            tree.close()
        end
    end,
    {
        desc = "File Explorer: toggle file explorer"
    }
)
--- go to first buffer opened
vim.keymap.set(
    "n", "<C-A-Right>",
    function()
        for _, bufwin in pairs(vim.api.nvim_list_wins()) do
            local buffer = vim.api.nvim_win_get_buf(bufwin)
            local filetype = vim.bo[buffer].filetype

            if filetype ~= "NvimTree" then
                vim.api.nvim_set_current_win(bufwin)
                break
            end
        end
    end,
    {
        desc = "File Explorer: toggle to first opened buffer if file explorer open"
    }
)

--- open file finder, telescope
vim.keymap.set(
    "n", "<leader>ff",
    _telescope_builtin.find_files,
    {
        desc = "Telescope: find files"
    }
)
vim.keymap.set(
    "n", "<leader>fg",
    _telescope_builtin.live_grep,
    {
        desc = "Telescope: live grep"
    }
)
vim.keymap.set(
    "n", "<leader>fb",
    _telescope_builtin.buffers,
    {
        desc = "Telescope: buffers"
    }
)
vim.keymap.set(
    "n", "<leader>ft",
    _telescope_builtin.help_tags,
    {
        desc = "Telescope: help tags"
    }
)
vim.keymap.set(
    "n", "<leader>fcmds",
    function ()
        vim.cmd("Telescope commands")
    end,
    {
        desc = "Telescope: find command/s"
    }
)
