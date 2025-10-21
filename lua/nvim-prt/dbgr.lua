-- ~/.config/nvim/lua/nvim-prt/dbgr.lua
local DBGR = {}

---

--[[
debuger note:
- c & cpp project: gdb or lldb
- rust project   : rust-gdb or rust-lldb
- js/ts project  : node or bun or deno?
- go project     : ?
--]]

---

DBGR.template = {
    dot_nvim_launch_json_content = [[
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

local maps = {
    dbgr_run = {},
    dbgr_stop = {},
    dbgr_breakpoint = {},

    dbgr_init_launch = {},

    dbgr_sessions_exit = {},
    dbgr_sessions_list = {},
    dbgr_sessions_until = {},
    dbgr_sessions_continue = {},
    dbgr_sessions_step_out = {},
    dbgr_sessions_step_over = {},
    dbgr_sessions_step_into = {},
}

local session = {
    active_sessions = {},
    breakpoints = {},
    configs = nil
}

local until_cmd = "until"
local continue_cmd = "continue"
local step_over_cmd = "next"
local step_into_cmd = "step"
local step_out_cmd = "finish"
local exit_cmd = "exit"

---

-- buffer-local keymaps for debug controls
local map_set = function(mode, lhs, rhs, desc, buf)
    vim.keymap.set(mode, lhs, rhs, {buffer = buf, desc = desc})
end

-- debug control functions
local function send_debugger_command(job_id, command)
    if job_id and vim.fn.jobwait({job_id}, 0)[1] == -1 then
        vim.api.nvim_chan_send(job_id, command .. "\n")
    end
end

-- internal maps_setup after setup opts.maps is passed
local function maps_setup()
    if not next(maps) then
        return
    end

    --#region dbgr launcher
    if maps.dbgr_run then
        vim.keymap.set("n", maps.dbgr_run[1], function()
            vim.ui.input({prompt = "Debug Config (from .nvim/launch.json): "}, function(input)
                if input then DBGR.start_debugging(input) end
            end)
        end, { desc = maps.dbgr_run[2] })
    end
    if maps.dbgr_stop then
        vim.keymap.set("n", maps.dbgr_stop[1], function()
            DBGR.stop_debugging("all")
            -- NOTE:
            -- * not automatically exit
            -- * enduser need to enter the terminal again and press "any" key
            -- * if need to be automatically close, look for the terminal buffer first
        end, { desc = maps.dbgr_stop[2] })
    end
    if maps.dbgr_breakpoint then
        vim.keymap.set("n", maps.dbgr_breakpoint[1], function()
            DBGR.toggle_breakpoint()
        end, { desc = maps.dbgr_breakpoint[2] })
    end
    --#endregion

    --#region dbgr init
    if maps.dbgr_init_launch then
        vim.keymap.set("n", maps.dbgr_init_launch[1], function()
            DBGR.init_launch()
        end, { desc = maps.dbgr_init_launch[2] })
    end
    --#endregion

    --#region dbgr debugger session
    -- go to "navigation controls"
    --#endregion

    -- notify: what is not set?
end

-- debug keymap
local function set_debug_keymaps(buf, job_id, debugger_type)
    if debugger_type == "gdb" then
        -- gdb commands
        until_cmd = "until"
        continue_cmd = "continue"
        step_over_cmd = "next"
        step_into_cmd = "step"
        step_out_cmd = "finish"
        exit_cmd = "exit"
    elseif debugger_type == "lldb" then
        -- lldb commands
        until_cmd = "until"
        continue_cmd = "continue"
        step_over_cmd = "next"
        step_into_cmd = "step"
        step_out_cmd = "finish"
        exit_cmd = "exit"
    elseif debugger_type == "node" then
        -- node inspect commands
        until_cmd = "until"
        continue_cmd = "cont"
        step_over_cmd = "next"
        step_into_cmd = "step"
        step_out_cmd = "out"
        exit_cmd = "exit"
    end

    -- navigation controls
    if next(maps) then
        map_set("n", maps.dbgr_sessions_continue[1], function()
            send_debugger_command(job_id, continue_cmd)
        end, maps.dbgr_sessions_continue[2], buf)
        map_set("n", maps.dbgr_sessions_step_over[1], function()
            send_debugger_command(job_id, step_over_cmd)
        end, maps.dbgr_sessions_step_over[2], buf)
        map_set("n", maps.dbgr_sessions_step_into[1], function()
            send_debugger_command(job_id, step_into_cmd)
        end, maps.dbgr_sessions_step_into[2], buf)
        map_set("n", maps.dbgr_sessions_step_out[1], function()
            send_debugger_command(job_id, step_out_cmd)
        end, maps.dbgr_sessions_step_out[2], buf)
        map_set("n", maps.dbgr_sessions_until[1], function()
            send_debugger_command(job_id, until_cmd)
        end, maps.dbgr_sessions_until[2], buf)
        map_set("n", maps.dbgr_sessions_exit[1], function()
            send_debugger_command(job_id, exit_cmd)
        end, maps.dbgr_sessions_exit[2], buf)
    end
end

local function find_project_root()
    local markers = { ".git", "Makefile", "package.json", "CMakeLists.txt", "Cargo.toml" }
    local path = vim.fn.expand("%:p:h")

    for _, marker in ipairs(markers) do
        local found = vim.fn.findfile(marker, path .. ";")
        if found ~= "" then
            return vim.fn.fnamemodify(found, ":h")
        end
    end
    return vim.fn.getcwd()
end

-- parse .nvim/launch.json in cwd
local function parse_launch_config()
    if session.configs then return session.configs end

    local root = find_project_root()
    local config_path = root .. "/.nvim/launch.json"

    if vim.fn.filereadable(config_path) == 0 then
        vim.notify("debug config not found: " .. config_path, vim.log.levels.WARN)
        return nil
    end

    local content = vim.fn.join(vim.fn.readfile(config_path), "\n")
    local ok, parsed = pcall(vim.json.decode, content)
    if not ok or not (parsed.configurations or parsed.compounds) then
        vim.notify("invalid launch.json format", vim.log.levels.ERROR)
        return nil
    end

    session.configs = parsed
    return parsed
end

local function execute_command(config)
    local cmd = config.runtime or config.program
    local args = config.args or {}
    local debugger = config.debugger or "gdb"  -- default to gdb

    -- prepare environment variables
    local env_vars = ""
    if config.environment then
        for k, v in pairs(config.environment) do
            env_vars = env_vars .. ("%s=%s "):format(k, v)
        end
    end

    -- create debugger command file with breakpoints
    local debugger_commands = {"run"}
    for _, bp in ipairs(session.breakpoints) do
        table.insert(debugger_commands, 1, ("break %s:%d"):format(bp.file, bp.line))
    end

    local script_path = os.tmpname() .. ".dbg"
    local script_content = table.concat(debugger_commands, "\n")
    local f = io.open(script_path, "w")
    if f then
        f:write(script_content)
        f:close()
    else
        vim.notify("failed to create debugger script", vim.log.levels.ERROR)
        return
    end

    -- build debugger command based on type
    local debugger_cmd
    if debugger == "lldb" then
        debugger_cmd = string.format("lldb -s %s -- %s %s",
            script_path, cmd, table.concat(args, " "))
    elseif debugger == "node" then
        debugger_cmd = string.format("node inspect %s %s",
            cmd, table.concat(args, " "))
    else  -- gdb
        debugger_cmd = string.format("gdb -q -x %s --args %s %s",
            script_path, cmd, table.concat(args, " "))
    end

    -- create terminal
    vim.cmd("belowright split")
    vim.cmd("resize 15")
    vim.cmd("terminal " .. env_vars .. debugger_cmd)

    local buf = vim.api.nvim_get_current_buf()
    local job_id = vim.b.terminal_job_id

    -- set buffer name with session ID
    local session_id = #session.active_sessions + 1
    vim.api.nvim_buf_set_name(buf, "DEBUG["..session_id.."]: "..config.name)
    vim.cmd("setlocal nobuflisted")

    -- set keymaps for debug control
    set_debug_keymaps(buf, job_id, debugger)

    -- track session
    session.active_sessions[job_id] = {
        id = session_id,
        name = config.name,
        job_id = job_id,
        buf = buf,
        config = config,
        debugger_script = script_path,
        debugger_type = debugger
    }

    return job_id
end

local function start_configuration(config)
    if not config or not config.program then
        vim.notify("invalid debug configuration", vim.log.levels.ERROR)
        return nil
    end

    -- resolve workspaceFolder variable
    if config.program:match("${workspaceFolder}") then
        config.program = config.program:gsub(
            "${workspaceFolder}",
            find_project_root()
        )
    end

    -- verify program exists
    if vim.fn.filereadable(config.program) == 0 then
        vim.notify("program not found: " .. config.program, vim.log.levels.ERROR)
        return nil
    end

    local job_id = execute_command(config)
    vim.notify("started debug session: " .. config.name, vim.log.levels.INFO)
    return job_id
end

-- start compound configuration
local function start_compound(compound)
    if not compound or not compound.configurations then
        vim.notify("invalid compound configuration", vim.log.levels.ERROR)
        return
    end

    local configs = parse_launch_config()
    if not configs then return end

    local session_ids = {}

    for _, conf_name in ipairs(compound.configurations) do
        for _, config in ipairs(configs.configurations) do
            if config.name == conf_name then
                local job_id = start_configuration(config)
                if job_id then
                    table.insert(session_ids, session.active_sessions[job_id].id)
                end
                break
            end
        end
    end

    vim.notify(("started compound [%s] with sessions: %s"):format(
        compound.name,
        table.concat(session_ids, ", ")
    ), vim.log.levels.INFO)
end

---

function DBGR.init_launch()
    local _prt = {
        nvim = require"nvim-prt.tools.nvim"
    }

    _prt.nvim.initialize()

    local destination = vim.fn.getcwd() .. "/.nvim/launch.json"

    if vim.uv.fs_stat(destination) then
        vim.notify(destination .. " already exists", vim.log.levels.INFO)
        return
    end

    local file = io.open(destination, "w")

    if not file then
        vim.notify("failed to open " .. destination, vim.log.levels.ERROR)
        return
    end

    if not file:write(DBGR.template.dot_nvim_launch_json_content) then
        vim.notify("failed to write " .. destination, vim.log.levels.ERROR)
        return
    end

    if not file:close() then
        vim.notify("failed to close " .. destination, vim.log.levels.ERROR)
        return
    end
end

function DBGR.start_debugging(name)
    local configs = parse_launch_config()
    if not configs then return end

    -- check for compound configuration
    if configs.compounds then
        for _, compound in ipairs(configs.compounds) do
            if compound.name == name then
                start_compound(compound)
                return
            end
        end
    end

    -- check for regular configuration
    for _, config in ipairs(configs.configurations) do
        if config.name == name then
            start_configuration(config)
            return
        end
    end

    vim.notify("no debug configuration found: " .. name, vim.log.levels.ERROR)
end

function DBGR.stop_debugging(name)
    if name == "all" then
        for job_id, sess in pairs(session.active_sessions) do
            vim.fn.jobstop(job_id)
            -- clean up debugger script
            if sess.debugger_script and vim.fn.filereadable(sess.debugger_script) == 1 then
                os.remove(sess.debugger_script)
            end
        end
        session.active_sessions = {}
        vim.notify("stopped all debug sessions", vim.log.levels.INFO)
        return
    end

    -- find session by name or ID
    for job_id, sess in pairs(session.active_sessions) do
        if tostring(sess.id) == name or sess.name == name then
            vim.fn.jobstop(job_id)
            -- clean up debugger script
            if sess.debugger_script and vim.fn.filereadable(sess.debugger_script) == 1 then
                os.remove(sess.debugger_script)
            end
            session.active_sessions[job_id] = nil
            vim.notify("stopped debug session: " .. sess.name, vim.log.levels.INFO)
            return
        end
    end

    vim.notify("no active session found: " .. name, vim.log.levels.WARN)
end

function DBGR.toggle_breakpoint()
    local file = vim.fn.expand("%:p")  -- use full path for breakpoints
    local line = vim.fn.line(".")

    -- check if breakpoint exists
    for i, bp in ipairs(session.breakpoints) do
        if bp.file == file and bp.line == line then
            table.remove(session.breakpoints, i)
            vim.fn.sign_unplace("debug_bp", { id = i })
            vim.notify("breakpoint removed at "..file..":"..line, vim.log.levels.INFO)
            return
        end
    end

    -- add new breakpoint
    table.insert(session.breakpoints, {file = file, line = line})

    -- create sign
    vim.fn.sign_define("debug_bp", {
        text = "",
        texthl = "DiagnosticError",
        linehl = "DebugBreakpoint"
    })
    vim.fn.sign_place(
        #session.breakpoints,
        "debug_bp",
        "debug_bp",
        vim.fn.bufnr(),
        { lnum = line }
    )

    vim.notify("breakpoint set at "..file..":"..line, vim.log.levels.INFO)
end

function DBGR.list_sessions()
    if not next(session.active_sessions) then
        vim.notify("no active debug sessions", vim.log.levels.INFO)
        return
    end

    local lines = {"active debug sessions:"}
    for _, sess in pairs(session.active_sessions) do
        table.insert(lines, ("[%d] %s - %s"):format(
            sess.id, sess.name, vim.fn.bufname(sess.buf)
        ))
    end

    vim.api.nvim_echo({ { table.concat(lines, "\n") } }, false, {})
end

-- new debug control functions
function DBGR.sessions_continue(session_id)
    local sess = session_id and DBGR.get_session(session_id) or DBGR.get_current_session()
    if sess then
        send_debugger_command(sess.job_id, "continue")
    else
        vim.notify("no active debug session found", vim.log.levels.WARN)
    end
end

function DBGR.sessions_step_over(session_id)
    local sess = session_id and DBGR.get_session(session_id) or DBGR.get_current_session()
    if sess then
        send_debugger_command(sess.job_id, "next")
    else
        vim.notify("no active debug session found", vim.log.levels.WARN)
    end
end

function DBGR.sessions_step_into(session_id)
    local sess = session_id and DBGR.get_session(session_id) or DBGR.get_current_session()
    if sess then
        send_debugger_command(sess.job_id, "step")
    else
        vim.notify("no active debug session found", vim.log.levels.WARN)
    end
end

function DBGR.sessions_step_out(session_id)
    local sess = session_id and DBGR.get_session(session_id) or DBGR.get_current_session()
    if sess then
        send_debugger_command(sess.job_id, "finish")
    else
        vim.notify("no active debug session found", vim.log.levels.WARN)
    end
end

function DBGR.session_exit(session_id)
    local sess = session_id and DBGR.get_session(session_id) or DBGR.get_current_session()
    if sess then
        send_debugger_command(sess.job_id, "exit")
    else
        vim.notify("no active debug session found", vim.log.levels.WARN)
    end
end

-- helper functions for session management
function DBGR.get_session(session_id)
    for _, sess in pairs(session.active_sessions) do
        if tostring(sess.id) == session_id or sess.name == session_id then
            return sess
        end
    end
    return nil
end

function DBGR.get_current_session()
    local buf = vim.api.nvim_get_current_buf()
    for _, sess in pairs(session.active_sessions) do
        if sess.buf == buf then
            return sess
        end
    end
    -- return first session if current buffer not found
    for _, sess in pairs(session.active_sessions) do
        return sess
    end
    return nil
end

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
    vim.fn.sign_define("debug_bp", {
        text = "",
        texthl = "DiagnosticError",
        linehl = "DebugBreakpoint"
    })

    -- create user commands
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_run, function(options)
        DBGR.start_debugging(options.args)
    end, {
        nargs = 1,
        complete = function()
            local configs = parse_launch_config()
            if not configs then return {} end

            local completions = {}
            for _, conf in ipairs(configs.configurations) do
                table.insert(completions, conf.name)
            end
            if configs.compounds then
                for _, comp in ipairs(configs.compounds) do
                    table.insert(completions, comp.name)
                end
            end
            return completions
        end
    })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_stop, function(options)
        DBGR.stop_debugging(options.args or "all")
    end, {
        nargs = "?",
        complete = function()
            local completions = {"all"}
            for _, sess in pairs(session.active_sessions) do
                table.insert(completions, tostring(sess.id))
                table.insert(completions, sess.name)
            end
            return completions
        end
    })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_list, DBGR.list_sessions, {})
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_breakpoint, DBGR.toggle_breakpoint, {})

    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_init_launch, DBGR.init_launch, {})

    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_continue, function(options)
        DBGR.sessions_continue(options.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_step_over, function(options)
        DBGR.sessions_step_over(options.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_step_into, function(options)
        DBGR.sessions_step_into(options.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_step_out, function(options)
        DBGR.sessions_step_out(options.args)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_sessions_exit, function(options)
        DBGR.session_exit(options.args)
    end, { nargs = "?" })

    if next(opts) ~= nil then
        if opts.maps then
            maps = opts.maps
            maps_setup()
        end
    end
end

---

return DBGR
