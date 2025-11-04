local _prt = {
    _ = require"nvim-prt",

    slr = require"nvim-prt.slr",

    cmdc = require"nvim-prt.cmdc",
    dbggr = require"nvim-prt.dbggr",
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

_prt.dbggr.setup({
    maps = {
        dbggr_run = {"<F5>", "DBGR: Run"},
        dbggr_stop = {"<F3>", "DBGR: Stop"},
        dbggr_breakpoint = {"<F4>", "DBGR: Breakpoint"},

        dbggr_init_launch = {"<F2>", "DBGR: Init Launch"},

        dbggr_sessions_exit = {"<F7>", "DBGR: Nav Sessions Exit"},
        dbggr_sessions_list = {"<F6>", "DBGR: Nav Sessions List"},
        dbggr_sessions_until = {"<F9>", "DBGR: Nav Sessions Until"},
        dbggr_sessions_continue = {"<F8>", "DBGR: Nav Session Continue"},
        dbggr_sessions_step_out = {"<F12>", "DBGR: Nav Sessions Step Out"},
        dbggr_sessions_step_over = {"<F10>", "DBGR: Nav Sessions Step Over"},
        dbggr_sessions_step_into = {"<F11>", "DBGR: Nav Sessions Step Into"},
    }
})

_prt.xplrr.setup()

_prt.slr.setup()
