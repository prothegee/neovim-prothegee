local _telescope = require"telescope"

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

    -- extensions = {},
}
