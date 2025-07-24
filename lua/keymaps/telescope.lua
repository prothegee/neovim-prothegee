local _telescope_builtin = require("telescope.builtin")

vim.keymap.set(
    "n", "<leader>ff",
    _telescope_builtin.find_files,
    {
        desc = "Telescope: find files",
        noremap = true,
        silent = true
    }
)
vim.keymap.set(
    "n", "<leader>fg",
    _telescope_builtin.live_grep,
    {
        desc = "Telescope: live grep",
        noremap = true,
        silent = true
    }
)
vim.keymap.set(
    "n", "<leader>fb",
    _telescope_builtin.buffers,
    {
        desc = "Telescope: buffers",
        noremap = true,
        silent = true
    }
)
vim.keymap.set(
    "n", "<leader>ft",
    _telescope_builtin.help_tags,
    {
        desc = "Telescope: help tags",
        noremap = true,
        silent = true

    }
)
vim.keymap.set(
    "n", "<leader>fc",
    function ()
        vim.cmd("Telescope commands")
    end,
    {
        desc = "Telescope: find command/s",
        noremap = true,
        silent = true
    }
)
