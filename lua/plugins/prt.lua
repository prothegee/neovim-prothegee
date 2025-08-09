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

_prt.dbgr.setup({
    maps = {
        dbgr_run = {"<F5>", "DBGR: Run"},
        dbgr_stop = {"<F3>", "DBGR: Stop"},
        dbgr_breakpoint = {"<F4>", "DBGR: Breakpoint"},

        dbgr_init_launch = {"<F2>", "DBGR: Init Launch"},

        dbgr_sessions_exit = {"<F7>", "DBGR: Nav Sessions Exit"},
        dbgr_sessions_list = {"<F6>", "DBGR: Nav Sessions List"},
        dbgr_sessions_until = {"<F9>", "DBGR: Nav Sessions Until"},
        dbgr_sessions_continue = {"<F8>", "DBGR: Nav Session Continue"},
        dbgr_sessions_step_out = {"<F12>", "DBGR: Nav Sessions Step Out"},
        dbgr_sessions_step_over = {"<F10>", "DBGR: Nav Sessions Step Over"},
        dbgr_sessions_step_into = {"<F11>", "DBGR: Nav Sessions Step Into"},
    }
})

_prt.xplrr.setup()
