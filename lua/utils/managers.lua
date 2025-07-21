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

-- rachartier/tiny-inline-diagnostic.nvim
local _line_diagnostic = require "tiny-inline-diagnostic"

_line_diagnostic.setup({
    preset = "modern",
    options = {
        multilines = {
            enabled = true,
            always_show = true,
            trim_whitespaces = true,
            tabstop = 4,
        },
        show_all_diags_on_cursorline = false
    },
})

-- lewis6991/gitsigns.nvim
local _gitsign = require "gitsigns"

_gitsign.setup({})
