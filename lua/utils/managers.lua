-- olimorris/onedarkpro.nvim
local _onedarkpro = require "onedarkpro"

_onedarkpro.setup({
    options = {
        transparency = true
    }
})
vim.cmd("colorscheme vaporwave")

-- nvim-tree/nvim-web-devicons
local _icon = require("nvim-web-devicons")

_icon.setup()

-- nvim-tree/nvim-tree.lua
local _nvim_tree = require "nvim-tree"

_nvim_tree.setup({
    view = {
        width = 33
    }
})

-- nvim-lualine/lualine.nvim
local _lualine = require "lualine"

_lualine.setup({
    options = {
        theme = "onedark"
    }
})

-- nvim-telescope/telescope.nvim
local _telescope = require("telescope")

_telescope.setup {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = " ",
        entry_prefix = " ",
        sorting_strategy = "ascending",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.5,
            },
            width = 0.9,
            height = 0.9,
        },
        mappings = {},
    },

    -- extensions_list = {
    --     "themes", "terms"
    -- },

    extensions = {},
}
