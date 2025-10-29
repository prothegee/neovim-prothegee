local DBGR = {}

---

--[[

# DBGR
DeBuGeR

---

NOTE:
- c & cpp project: gdb or lldb
- rust project   : rust-gdb or rust-lldb
- js/ts project  : node or bun or deno?
- go project     : ?
--]]

---

DBGR.template = {
    dot_nvim_dbgr_json_content = [[
{
    "version": "0.2.0",
    "configurations": [
        // {
        //     "name": "Cpp Sample",
        //     "type": "cpp",
        //     "program": "${workspaceFolder}/build/debug/app_cpp",
        //     "debugger": "gdb"
        // },
        // {
        //     "name": "Rust Example",
        //     "type": "rust",
        //     "program": "${workspaceFolder}/target/debug/app_rust",
        //     "debugger": "lldb"
        // },
        // {
        //     "name": "Node Example",
        //     "type": "node",
        //     "program": "${workspaceFolder}/app_javascript.js",
        //     "debugger": "node"
        // },
        // {
        //     "name": "Node Example",
        //     "type": "go",
        //     "program": "${workspaceFolder}/app_go.go",
        //     "debugger": "node"
        // },
    ],
    "compounds": [
        {
            "name": "Full System",
            "configurations": [
                // "Cpp Sample", "Rust Example", "Node Example", "Go Example"
            ]
        }
    ]
}
    ]]
}

---

-- RESERVED

---

DBGR.cmd = {
    dbgr_run = "DbgrRun",
    dbgr_stop = "DbgrStop",
    dbgr_breakpoint = "DbgrBreakpoint",

    dbgr_init_launch = "DbgrInitLaunch",

    dbgr_sessions_exit = "DbgrSessionsExit",
    dbgr_sessions_list = "DbgrSessionsList",
    dbgr_sessions_continue = "DbgrSessionsContinue",
    dbgr_sessions_step_out = "DbgrSessionsStepOut",
    dbgr_sessions_step_over = "DbgrSessionsStepOver",
    dbgr_sessions_step_into = "DbgrSessionsStepInto",
}

---

function DBGR.setup(opts)
    opts = opts or {}

    -- define breakpoint sign once
    vim.fn.sign_define("dbgr_debug_breakpoint", {
        text = "",
        texthl = "DbgrDiagnosticError",
        linehl = "DbgrDebugBreakpoint"
    })

    -- RESERVED
end

---

return DBGR

