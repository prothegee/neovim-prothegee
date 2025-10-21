vim.schedule(function()
    require"settings.global"
    require"settings.diagnostic"

    require"settings.theme"
    require"settings.option"

    require"settings.commands"
    require"settings.keymaps"
    require"settings.lsps"
    require"settings.treesitters"
end)

