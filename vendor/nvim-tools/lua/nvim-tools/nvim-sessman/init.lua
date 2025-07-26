local NVIM_SESSMAN = {}

local _nvimtools = {
    config = require"nvim-tools.config",
    utils = require"nvim-tools.utils",
    format = require"nvim-tools.format"
}

---

NVIM_SESSMAN.name = "nvim-sessman"

NVIM_SESSMAN.opts = {
    init_dot_nvim_dir = true
}

NVIM_SESSMAN.conf = {
    auto_save = false,
    auto_load = false
}

NVIM_SESSMAN.dirs = {
    nvim_session = ".nvim/sessman"
}

NVIM_SESSMAN.files = {
    nvim_tree = ".nvim/sessman/nvim-tree.json",
    nvim_session = ".nvim/sessman/session.json",
    nvim_buffers = ".nvim/session/nvim-buffers.json"
}

NVIM_SESSMAN.template = {
    nvim_session = [[
{
    "auto_save": false,
    "auto_load": false
}
]],

    nvim_session_nvim_tree = [[
{
    "is_open": false,
    "opened_dirs": []
}
]],

    nvim_session_buffers = [[
{
    "opened_buffers": []
}
]]
}

---

local save_state_nvim_tree = function(file_path)
    local ok, api = pcall(require, "nvim-tree.api")

    if not ok then return end

    local tree_state = {
        is_open = api.tree.is_vissible(),
        opened_dirs = {}
    }

    if tree_state.is_open then
        tree_state.opened_dirs = { vim.fn.getcwd() }
    end
end

local save_state_buffers = function(file_path)
    local buffers = {}

    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].buflisted then
            local name = vim.api.nvim_buf_get_name(buffer)

            -- only include valid/exists buffers
            if  name ~= "" and name ~= "[No Name]" and vim.fn.filereadable(name) == 1 then
                table.insert(buffers, name)
            end
        end
    end

    _nvimtools.utils.write_json_file(vim.fn.getcwd() .. "/" .. file_path, { opened_buffers = buffers })
end

local remove_buffer_from_session = function(bufnr, file_path)
    local buffers_file = vim.fn.getcwd() .. "/" .. file_path
    local data = _nvimtools.utils.read_json_file(buffers_file)
    if not data or not data.opened_buffers then return end

    local buf_path = vim.api.nvim_buf_get_name(bufnr)

    -- skip empty, [No Name], and non-file buffers
    if buf_path == "" or buf_path == "[No Name]" or vim.fn.filereadable(buf_path) ~= 1 then
        return
    end

    local new_buffers = {}
    for _, path in ipairs(data.opened_buffers) do
        if path ~= buf_path and
           path ~= "[No Name]" and
           path ~= "" then
            table.insert(new_buffers, path)
        end
    end

    data.opened_buffers = new_buffers
    _nvimtools.utils.write_json_file(buffers_file, data)
end

local load_state_buffers = function(file_path)
    local data = _nvimtools.format.read_json_file(vim.fn.getcwd() .. "/" .. file_path)
    if not data or not data.opened_buffers then return end

    -- track loaded buffers to prevent duplicates
    local loaded_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            loaded_buffers[name] = true
        end
    end

    -- close all empty buffers before loading session
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" or name == "[No Name]" then
            if vim.api.nvim_buf_is_loaded(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    end

    for _, buf_path in ipairs(data.opened_buffers) do
        -- skip [No Name] and empty paths, and already loaded buffers
        if buf_path ~= "[No Name]" and
           buf_path ~= "" and
           not loaded_buffers[buf_path] and
           vim.fn.filereadable(buf_path) == 1 then
            vim.cmd("edit " .. buf_path)
            loaded_buffers[buf_path] = true  -- mark as loaded
        end
    end
end

local load_state_nvim_tree = function(file_path)
    local data = _nvimtools.utils.read_json_file(vim.fn.getcwd() .. "/" .. file_path)
    if not data then return end

    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then return end

    if data.is_open and not api.tree.is_visible() then
        api.tree.open()
    elseif not data.is_open and api.tree.is_visible() then
        api.tree.close()
    end
end

---

NVIM_SESSMAN.autosave_setup_hint = "Nvim SessMan: Autosave Toggle"
function NVIM_SESSMAN.autosave_setup()
    local session_file = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.file.nvim_session
    local data = _nvimtools.utils.read_json_file(session_file) or { use_autosave = false }

    data.use_autosave = not data.use_autosave
    _nvimtools.utils.write_json_file(session_file, data)

    NVIM_SESSMAN.conf.auto_save = data.use_autosave
    vim.notify("Autosave " .. (data.use_autosave and "enabled" or "disabled"), vim.log.levels.INFO)
end

NVIM_SESSMAN.autoload_setup_hint = "Nvim SessMan: Autoload Toggle"
function NVIM_SESSMAN.autoload_setup()
    local session_file = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.file.nvim_session
    local data = NVIM_SESSMAN.read_json_file(session_file) or { use_autoload = false }

    data.use_autoload = not data.use_autoload
    NVIM_SESSMAN.write_json_file(session_file, data)

    NVIM_SESSMAN.conf.auto_load = data.use_autoload
    vim.notify("Autoload " .. (data.use_autoload and "enabled" or "disabled"), vim.log.levels.INFO)
end

NVIM_SESSMAN.save_hint = "Nvim SessMan: Save"
function NVIM_SESSMAN.save()
    save_state_nvim_tree(NVIM_SESSMAN.file.nvim_tree)
    save_state_buffers(NVIM_SESSMAN.file.nvim_buffers)
    vim.notify("Nvim SessMan: Session Saved", vim.log.levels.INFO)
end

NVIM_SESSMAN.load_hint = "Nvim SessMan: Load"
function NVIM_SESSMAN.load()
    load_state_nvim_tree(NVIM_SESSMAN.file.nvim_tree)
    load_state_buffers(NVIM_SESSMAN.file.nvim_buffers)

    -- close all empty buffers after manual load
    vim.schedule(function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name == "" or name == "[No Name]" then
                if vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end
        end
    end)

    vim.notify("Nvim SessMan: Session Loaded", vim.log.levels.INFO)
end

---

function NVIM_SESSMAN.init_session()
    local target = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.files.nvim_session
    _nvimtools.utils.write_file(target, NVIM_SESSMAN.template.nvim_session)
end

function NVIM_SESSMAN.init_session_buffers()
    local target = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.files.nvim_buffers
    _nvimtools.utils.write_file(target, NVIM_SESSMAN.template.nvim_session_buffers)
end

function NVIM_SESSMAN.init_session_nvim_tree()
    if not _nvimtools.config.has_nvim_tree() then
        vim.notify("WARN: nvim-tree is not found", vim.log.levels.WARN)
        return
    end
    local target = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.files.nvim_tree
    _nvimtools.utils.write_file(target, NVIM_SESSMAN.template.nvim_session_nvim_tree)
end

function NVIM_SESSMAN.init_autosave()
    local session_data = _nvimtools.utils.read_json_file(vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.file.nvim_session)
    if not session_data then return end

    NVIM_SESSMAN.conf.auto_save = session_data.use_autosave or false

    if NVIM_SESSMAN.conf.auto_save then
        -- save session on VimLeave
        vim.api.nvim_create_autocmd("VimLeave", {
            callback = function()
                save_state_nvim_tree(NVIM_SESSMAN.file.nvim_tree)
                save_state_buffers(NVIM_SESSMAN.file.nvave_buffers_stateim_buffers)
            end
        })

        -- update buffers list on buffer write
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                save_state_buffers(NVIM_SESSMAN
.file.nvim_buffers)
            end
        })

        -- remove buffer when closed
        vim.api.nvim_create_autocmd("BufDelete", {
            callback = function(args)
                remove_buffer_from_session(args.buf, NVIM_SESSMAN.file.nvim_buffers)
            end
        })
    end
end

function NVIM_SESSMAN.init_autoload()
    local data = _nvimtools.utils.read_json_file(vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.file.nvim_session)

    if not data then return end

    NVIM_SESSMAN.conf.auto_load = data.auto_load or false

    if NVIM_SESSMAN.conf.auto_load then
        load_state_buffers(NVIM_SESSMAN.file.nvim_buffers)
        load_state_nvim_tree(NVIM_SESSMAN.file.nvim_tree)

        -- close the initial empty buffer if session buffer found
        local has_session_buffers = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" and name ~= "[No Name]" then
                has_session_buffers = true
                break
            end
        end

        if has_session_buffers then
            vim.schedule(function()
                -- close all empty buffers
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name == "" or name == "[No Name]" then
                        if vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
                            vim.api.nvim_buf_delete(buf, { force = true })
                        end
                    end
                end
            end)
        end
    end
end

---

function NVIM_SESSMAN.setup(opts)
    opts = vim.tbl_deep_extend("force", NVIM_SESSMAN.opts, opts or {})

    if opts.init_dot_nvim_dir then
        local dir_to_create = vim.fn.getcwd() .. "/" .. NVIM_SESSMAN.dirs.nvim_session

        if vim.fn.isdirectory(dir_to_create) == 0 then
            vim.fn.mkdir(dir_to_create, "p")
        end
    end

    NVIM_SESSMAN.init_autosave()
    NVIM_SESSMAN.init_autoload()
end

---

return NVIM_SESSMAN
