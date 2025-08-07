-- ~/.config/nvim/lua/nvim-prt/dbgr.lua
local DBGR = {}

local session = {
    active_sessions = {},
    breakpoints = {},
    configs = nil
}

-- debug control functions
local function send_gdb_command(job_id, command)
    if job_id and vim.fn.jobwait({job_id}, 0)[1] == -1 then
        vim.api.nvim_chan_send(job_id, command .. "\n")
    end
end

local function set_debug_keymaps(buf, job_id)
    -- buffer-local keymaps for debug controls
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, {buffer = buf, desc = desc})
    end

    -- navigation controls
    map("n", "<F5>", function() send_gdb_command(job_id, "continue") end, "continue")
    map("n", "<F10>", function() send_gdb_command(job_id, "next") end, "step over")
    map("n", "<F11>", function() send_gdb_command(job_id, "step") end, "step into")
    map("n", "<F12>", function() send_gdb_command(job_id, "finish") end, "step out")
    map("n", "<F9>", function() send_gdb_command(job_id, "until") end, "run to cursor")

    -- inspection commands
    map("n", "<leader>dp", function()
        local word = vim.fn.expand("<cword>")
        if word ~= "" then
            send_gdb_command(job_id, "print " .. word)
        end
    end, "print variable")

    map("n", "<leader>db", DBGR.toggle_breakpoint, "toggle breakpoint")
    map("n", "<leader>dB", function()
        local line = vim.fn.line(".")
        local file = vim.fn.expand("%:p")
        send_gdb_command(job_id, "break " .. file .. ":" .. line)
    end, "set breakpoint at line")

    -- session controls
    map("n", "<leader>dq", function() DBGR.stop_debugging("all") end, "stop debug")
    map("n", "<leader>dr", function() send_gdb_command(job_id, "run") end, "restart debug")
end

local function find_project_root()
    local markers = { ".git", "Makefile", "package.json", "CMakeLists.txt" }
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

    -- create gdb command file with breakpoints
    local gdb_commands = {"run"}
    for _, bp in ipairs(session.breakpoints) do
        table.insert(gdb_commands, 1, ("break %s:%d"):format(bp.file, bp.line))
    end

    local gdb_script_path = os.tmpname() .. ".gdb"
    local gdb_script = table.concat(gdb_commands, "\n")
    local f = io.open(gdb_script_path, "w")
    if f then
        f:write(gdb_script)
        f:close()
    else
        vim.notify("failed to create gdb script", vim.log.levels.ERROR)
        return
    end

    -- build gdb command
    local gdb_cmd = string.format("%s -q -x %s --args %s %s",
        debugger, gdb_script_path, cmd, table.concat(args, " "))

    -- create terminal
    vim.cmd("belowright split")
    vim.cmd("resize 15")
    vim.cmd("terminal " .. env_vars .. gdb_cmd)

    local buf = vim.api.nvim_get_current_buf()
    local job_id = vim.b.terminal_job_id

    -- set buffer name with session ID
    local session_id = #session.active_sessions + 1
    vim.api.nvim_buf_set_name(buf, "DEBUG["..session_id.."]: "..config.name)
    vim.cmd("setlocal nobuflisted")

    -- set keymaps for debug control
    set_debug_keymaps(buf, job_id)

    -- track session
    session.active_sessions[job_id] = {
        id = session_id,
        name = config.name,
        job_id = job_id,
        buf = buf,
        config = config,
        gdb_script = gdb_script_path
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
            -- clean up gdb script
            if sess.gdb_script and vim.fn.filereadable(sess.gdb_script) == 1 then
                os.remove(sess.gdb_script)
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
            -- clean up gdb script
            if sess.gdb_script and vim.fn.filereadable(sess.gdb_script) == 1 then
                os.remove(sess.gdb_script)
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

---

DBGR.cmd = {
    dbgr_start = "DbgrStart",
    dbgr_stop = "DbgrStop",
    dbgr_list_sessions = "DbgrListSessions",
    dbgr_toggle_breakpoint = "DbgrToggleBreakpoint",
}

---

function DBGR.setup()
    -- define breakpoint sign once
    vim.fn.sign_define("debug_bp", {
        text = "",
        texthl = "DiagnosticError",
        linehl = "DebugBreakpoint"
    })

    -- create user commands
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_start, function(opts)
        DBGR.start_debugging(opts.args)
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
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_stop, function(opts)
        DBGR.stop_debugging(opts.args or "all")
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
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_list_sessions, DBGR.list_sessions, {})
    vim.api.nvim_create_user_command(DBGR.cmd.dbgr_toggle_breakpoint, DBGR.toggle_breakpoint, {})

    -- set key mappings (tmp unused)
    vim.keymap.set("n", "<leader>db", DBGR.toggle_breakpoint, { desc = "toggle breakpoint" })
    vim.keymap.set("n", "<leader>ds", function()
        vim.ui.input({prompt = "debug config: "}, function(input)
                if input then DBGR.start_debugging(input) end
            end)
        end,
    { desc = "start debug session" })
    vim.keymap.set("n", "<leader>dl", DBGR.list_sessions, { desc = "list sessions" })
    vim.keymap.set("n", "<leader>dq", function() DBGR.stop_debugging("all") end, { desc = "stop all debug" })
end

---

return DBGR
