local _prt = {
    _ = require"nvim-prt",

    cmdc = require"nvim-prt.cmdc",
    dbgr = require"nvim-prt.dbgr",
    xplrr = require"nvim-prt.xplrr",

    cmake = require"nvim-prt.tools.cmake"
}

_prt.cmdc.setup({
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

_prt.dbgr.setup()

_prt.xplrr.setup()
