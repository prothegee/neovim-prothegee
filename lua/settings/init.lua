vim.schedule(function()
    require"settings.lsp"
    require"settings.treesitter"
    -- skip capabilities, used in lsp
    require"settings.theme"
    require"settings.option"
    require"settings.global"

    require"settings.commands"
    require"settings.keymaps"
    require"settings.diagnostic"
end)

