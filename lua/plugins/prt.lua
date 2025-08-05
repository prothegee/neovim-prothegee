local _prt = {
    _ = require"nvim-prt",
    cmake = require"nvim-prt.tools.cmake"
}

_prt._.setup({
    default = true
})

require"nvim-prt.cmdc".setup({
    commands = {
        [_prt.cmake.preset_init_hint] = function()
            _prt.cmake.preset_init()
        end,
        [_prt.cmake.preset_select_hint] = function()
            _prt.cmake.preset_select()
        end,
        [_prt.cmake.project_clean_hint] = function()
            _prt.cmake.project_clean()
        end,
        [_prt.cmake.project_configure_hint] = function()
            _prt.cmake.project_configure()
        end,
        [_prt.cmake.project_configure_build_hint] = function()
            _prt.cmake.project_configure_build()
        end,
    }
})
