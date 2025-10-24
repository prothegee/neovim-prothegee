local XPLRR = {}

---

local config = {
    hidden = true,
    follow_symlinks = false,
    max_results = 1024,
    border = "rounded",
    highlight_ns = vim.api.nvim_create_namespace("XPLRR_HL"),
}

-- state management
local state = {
    buf = nil,
    win = nil,
    search_term = "",
    results = {},
    selected_index = 0,
    cwd = vim.fn.getcwd(),
    extmark_id = nil,
    all_files = {},             -- cache all files in the directory
    original_win = nil,         -- origin window before opening finder
    header_lines = 2,           -- n of fixed header lines
    mode = "files",             -- "files", "buffers", or "all"
    buf_keymaps = {},           -- stores keymaps to clear later
    win_closed_autocmd = nil,   -- tracks window autocommand
}

local function is_windows()
    return package.config:sub(1,1) == "\\"
end

local function shorten_path(path)
    local home = vim.env.HOME or vim.env.USERPROFILE
    if home then
        home = home:gsub("\\", "/")
        local normalized_path = path:gsub("\\", "/")
        if normalized_path:sub(1, #home) == home then
            return "~" .. normalized_path:sub(#home + 1)
        end
    end
    return path
end

local function is_valid_buf(buf)
    return buf and vim.api.nvim_buf_is_valid(buf)
end

local function load_ignore_patterns()
    local ignore_file = state.cwd .. "/.nvimignore"
    local patterns = {}

    local file = io.open(ignore_file, "r")
    if not file then
        return patterns
    end

    for line in file:lines() do
        -- remove comments and trim whitespace
        local clean_line = line:gsub("#.*$", ""):gsub("^%s*(.-)%s*$", "%1")
        if clean_line ~= "" then
            table.insert(patterns, clean_line)
        end
    end

    file:close()
    return patterns
end

local function should_ignore(file_path, ignore_patterns)
    if not ignore_patterns or #ignore_patterns == 0 then
        return false
    end

    for _, pattern in ipairs(ignore_patterns) do
        -- clean the pattern (remove trailing slashes for comparison)
        local clean_pattern = pattern:gsub("/+$", "")

        -- exact match for files/directories
        if file_path == clean_pattern then
            return true
        end

        -- directory pattern (ends with /) - match directory and its contents
        if pattern:sub(-1) == "/" then
            local dir_pattern = pattern:sub(1, -2)
            -- Match directory itself or any file inside it
            if file_path == dir_pattern or file_path:sub(1, #dir_pattern + 1) == dir_pattern .. "/" then
                return true
            end
        else
            -- wildcard matching
            if pattern:find("*") then
                -- convert wildcard pattern to Lua pattern
                local regex_pattern = "^" .. pattern:gsub("%.", "%%."):gsub("%*", ".*") .. "$"
                if file_path:match(regex_pattern) then
                    return true
                end
            end

            -- simple directory match without trailing slash
            if file_path:sub(1, #clean_pattern + 1) == clean_pattern .. "/" then
                return true
            end
        end
    end

    return false
end

local function scan_directory(dir, use_ignore)
    local files = {}
    local ignore_patterns = use_ignore and load_ignore_patterns() or {}

    local function scan_recursive(current_dir)
        local handle, err = vim.loop.fs_scandir(current_dir)
        if not handle then
            -- silently skip directories we can't access
            if err:match("Permission denied") then
                return
            else
                vim.notify("Error scanning directory: " .. err, vim.log.levels.WARN)
                return
            end
        end

        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end

            local full_path = current_dir .. "/" .. name
            local rel_path = full_path:sub(#state.cwd + 2) -- +2 to remove leading slash

            -- skip hidden files if not configured to show them
            if not config.hidden and name:sub(1, 1) == "." then
                goto continue
            end

            if type == "file" then
                -- check if file should be ignored
                if not should_ignore(rel_path, ignore_patterns) then
                    table.insert(files, rel_path)
                end
            elseif type == "directory" then
                -- check if directory should be ignored
                if not should_ignore(rel_path, ignore_patterns) then
                    -- recursively scan subdirectory
                    scan_recursive(full_path)
                end
            end

            ::continue::
        end
    end

    scan_recursive(dir)
    return files
end

local function get_open_buffers(use_ignore)
    local buffers = {}
    local ignore_patterns = use_ignore and load_ignore_patterns() or {}

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
            local file = vim.api.nvim_buf_get_name(buf)
            if file and file ~= "" then
                -- normalize path
                file = file:gsub("\\", "/")

                -- make relative to cwd
                local cwd_normalized = state.cwd:gsub("\\", "/")
                if cwd_normalized:sub(-1) ~= "/" then
                    cwd_normalized = cwd_normalized .. "/"
                end

                if file:sub(1, #cwd_normalized) == cwd_normalized then
                    file = file:sub(#cwd_normalized + 1)
                end

                -- skip if buffer matches ignore patterns and use_ignore is true
                if not (use_ignore and should_ignore(file, ignore_patterns)) then
                    table.insert(buffers, file)
                end
            end
        end
    end
    return buffers
end

local function fuzzy_match(term, str)
    if #term == 0 then return true end
    term = term:lower()
    str = str:lower()

    local j = 1  -- position in str
    for i = 1, #term do
        local c = term:sub(i, i)
        local found = false

        while j <= #str do
            if str:sub(j, j) == c then
                found = true
                j = j + 1
                break
            end
            j = j + 1
        end
        if not found then return false end
    end
    return true
end

local function update_results()
    if #state.search_term == 0 then
        state.results = {}

        -- show all files when search is empty
        for i = 1, math.min(#state.all_files, config.max_results) do
            table.insert(state.results, state.all_files[i])
        end
    else
        state.results = {}
        local matches = {} -- will hold {file, score}
        local lower_term = state.search_term:lower()

        -- filter files based on search term
        for _, file in ipairs(state.all_files) do
            local lower_file = file:lower()
            if fuzzy_match(lower_term, lower_file) then
                -- prioritize exact substring matches at the beginning
                local score = 0
                local start_index = string.find(lower_file, lower_term, 1, true) -- plain search

                if start_index then
                    -- exact match bonus: earlier start gets lower score
                    score = start_index - 1000000
                else
                    -- find first occurrence of first char for fuzzy matches
                    local first_char = lower_term:sub(1, 1)
                    start_index = string.find(lower_file, first_char, 1, true) or 1
                    score = start_index
                end

                -- secondary sort: shorter paths first
                score = score + #file * 0.000001

                table.insert(matches, { file = file, score = score  })
            end
        end

        -- sort by score (lower is better)
        table.sort(matches, function(a, b)
            if a.score == b.score then
                return a.file < b.file
            end
            return a.score < b.score
        end)

        -- take top results
        for i = 1, math.min(#matches, config.max_results) do
            table.insert(state.results, matches[i].file)
        end
    end

    -- adjustment selection index
    if #state.results > 0 then
        if state.selected_index == 0 then
            -- keep selection in search input
        elseif state.selected_index > #state.results then
            state.selected_index = #state.results
        end
    else
        state.selected_index = 0
    end
end

local function open_file(filepath)
    local full_path
    if filepath:match("^/") or (is_windows() and filepath:match("^%a:\\")) then
        full_path = filepath
    else
        full_path = state.cwd.."/"..filepath
    end
    full_path = full_path:gsub("/+", "/") -- normalize path

    -- switch to original window and open file there
    if state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
        vim.api.nvim_set_current_win(state.original_win)

        -- run :edit command to properly handle buffer loading
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        return true
    else
        -- fallback to current window
        vim.cmd("edit " .. vim.fn.fnameescape(full_path))
        return true
    end
end

local function update_display()
    if not is_valid_buf(state.buf) then return end

    -- shortened path for display
    local display_cwd = shorten_path(state.cwd)
    local title = "XPLRR"
    if state.mode == "files" then
        title = "XPLRR: " .. display_cwd
    elseif state.mode == "buffers" then
        title = "XPLRR Buffers"
    elseif state.mode == "all" then
        title = "XPLRR All: " .. display_cwd
    end

    local display_lines = {
        title,
        "> "..state.search_term
    }

    state.header_lines = #display_lines -- set header lines count here

    -- add search input and results
    for i, result in ipairs(state.results) do
        local prefix = (state.selected_index == i) and "➤ " or "  "
        table.insert(display_lines, prefix..result)
    end

    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, display_lines)

    -- clear previous highlight
    if state.extmark_id then
        vim.api.nvim_buf_del_extmark(state.buf, config.highlight_ns, state.extmark_id)
        state.extmark_id = nil
    end

    -- highlight active line with full-width block
    if state.selected_index > 0 then
        local line_index = state.header_lines + state.selected_index - 1
        state.extmark_id = vim.api.nvim_buf_set_extmark(
            state.buf,
            config.highlight_ns,
            line_index,     -- line number (0-based)
            0,              -- starting column
            {
                hl_group = "visual",
                end_line = line_index + 1,
                end_col = 0,                -- 0 = start of next line
                priority = 100,             -- ensure it's above syntax hightlight
            }
        )
    end
end

local function close_window()
    -- remove window autocommand
    if state.win_closed_autocmd then
        pcall(vim.api.nvim_del_autocmd, state.win_closed_autocmd)
        state.win_closed_autocmd = nil
    end

    -- clear highlight
    if state.extmark_id and is_valid_buf(state.buf) then
        vim.api.nvim_buf_del_extmark(state.buf, config.highlight_ns, state.extmark_id)
    end

    -- remove all keymaps we created
    if state.buf_keymaps and is_valid_buf(state.buf) then
        for _, keymap in ipairs(state.buf_keymaps) do
            local mode, lhs = keymap[1], keymap[2]
            pcall(vim.api.nvim_buf_del_keymap, state.buf, mode, lhs)
        end
        state.buf_keymaps = {}
    end

    -- close window
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    state.buf = nil
    state.win = nil
    state.extmark_id = nil

    -- ensure we're back in normal mode
    vim.api.nvim_command("stopinsert")
    if state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
        vim.api.nvim_set_current_win(state.original_win)
        vim.api.nvim_command("stopinsert")
    end
end

local function create_window(mode)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        return
    end

    -- remember original window
    state.original_win = vim.api.nvim_get_current_win()
    state.mode = mode or "files"

    -- create buffer
    state.buf = vim.api.nvim_create_buf(false, true)
    if not is_valid_buf(state.buf) then
        vim.notify("failed to create XPLRR buffer", vim.log.levels.ERROR)
        return
    end

    -- get files based on mode
    state.cwd = vim.fn.getcwd()
    if mode == "buffers" then
        state.all_files = get_open_buffers(false) -- don't use ignore for buffers mode
    elseif mode == "files" then
        -- combine files from directory (with ignore) and buffers (without ignore)
        local dir_files = scan_directory(state.cwd, true) -- use ignore for directory files
        local buffer_files = get_open_buffers(false) -- don't use ignore for buffers

        -- merge and remove duplicates
        local all_files_map = {}
        for _, file in ipairs(dir_files) do
            all_files_map[file] = true
        end
        for _, file in ipairs(buffer_files) do
            all_files_map[file] = true
        end

        state.all_files = {}
        for file, _ in pairs(all_files_map) do
            table.insert(state.all_files, file)
        end
        table.sort(state.all_files)
    else
        state.all_files = scan_directory(state.cwd, false) -- don't use ignore for regular files mode
    end

    state.search_term = ""
    state.selected_index = 0
    update_results()

    -- window dimensions
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.6)

    -- window options
    local title = "XPLRR"
    if state.mode == "files" then
        title = "XPLRR"
    elseif state.mode == "buffers" then
        title = "XPLRR Buffers"
    elseif state.mode == "all" then
        title = "XPLRR All"
    end

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = "minimal",
        border = config.border,
        title = title,
        title_pos = "center",
    }

    -- create window
    state.win = vim.api.nvim_open_win(state.buf, true, win_opts)
    if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        vim.notify("failed to create XPLRR window", vim.log.levels.ERROR)
        return
    end

    -- set buffer options
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].filetype = "xplrr"
    vim.bo[state.buf].omnifunc = "v:lua.vim.lsp.omnifunc"  -- prevent E764
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].bufhidden = "wipe"

    -- navigation functions
    --- move up
    local function move_up()
        if state.selected_index == 0 then
            -- already at top, do nothing
        elseif state.selected_index == 1 then
            -- move from first file to search input
            state.selected_index = 0
            update_display()
            vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
            vim.api.nvim_command("startinsert")

            -- ensure header is visible
            vim.fn.winrestview({topline = 1})
        else
            -- move up in file list
            state.selected_index = state.selected_index - 1
            update_display()
            -- corrected line index calculation
            vim.api.nvim_win_set_cursor(state.win, {state.selected_index + state.header_lines, 0})

            -- keep header in view when near top
            if state.selected_index == 1 then
                vim.fn.winrestview({topline = 1})
            end
        end
    end
    --- move down
    local function move_down()
        if state.selected_index == 0 then
            -- move from search input to first file
            if #state.results > 0 then
                state.selected_index = 1
                update_display()
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines + state.selected_index - 1, 0})
                vim.fn.winrestview({topline = 1})
            end
        elseif state.selected_index < #state.results then
            -- move down in file list
            state.selected_index = state.selected_index + 1
            update_display()
            vim.api.nvim_win_set_cursor(state.win, {state.selected_index + state.header_lines, 0})

            -- ensure header is visible
            vim.fn.winrestview({topline = 1})
        end
    end

    local mappings = {
        {"n", "<CR>", function()
            if state.selected_index == 0 and #state.results > 0 then
                -- open first result when pressing Enter in search input
                if open_file(state.results[1]) then
                    close_window()
                end
            elseif state.selected_index > 0 then
                if open_file(state.results[state.selected_index]) then
                    close_window()
                end
            end
        end, {buffer = state.buf}},

        {"i", "<CR>", function()
            if state.selected_index == 0 and #state.results > 0 then
                -- open first result when pressing Enter in search input
                if open_file(state.results[1]) then
                    close_window()
                end
            elseif state.selected_index > 0 then
                if open_file(state.results[state.selected_index]) then
                    close_window()
                end
            end
        end, {buffer = state.buf}},

        {"n", "<C-q>", close_window, {buffer = state.buf}},
        {"i", "<C-q>", close_window, {buffer = state.buf}},

        {"n", "<Up>", move_up, {buffer = state.buf}},
        {"i", "<Up>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = state.buf}},

        {"n", "<Down>", move_down, {buffer = state.buf}},
        {"i", "<Down>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = state.buf}},

        {"n", "<C-n>", move_down, {buffer = state.buf}},
        {"i", "<C-n>", function()
            vim.api.nvim_command("stopinsert")
            move_down()
        end, {buffer = state.buf}},

        {"n", "<C-p>", move_up, {buffer = state.buf}},
        {"i", "<C-p>", function()
            vim.api.nvim_command("stopinsert")
            move_up()
        end, {buffer = state.buf}},

        -- disable left/right navigation in file list
        {"n", "<Left>", "<Nop>", {buffer = state.buf}},
        {"n", "<Right>", "<Nop>", {buffer = state.buf}},
        {"i", "<Left>", "<Nop>", {buffer = state.buf}},
        {"i", "<Right>", "<Nop>", {buffer = state.buf}},
    }

    -- store and set keymaps
    state.buf_keymaps = {}
    for _, map in ipairs(mappings) do
        local mode, lhs = map[1], map[2]
        table.insert(state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, map[3], map[4])
    end

    -- add printable character mappings to return to input field
    local printable_chars = ""
    for i = 32, 126 do
        printable_chars = printable_chars .. string.char(i)
    end

    for i = 1, #printable_chars do
        local char = printable_chars:sub(i, i)
        local mode = "n"
        local lhs = char
        local rhs = function()
            if state.selected_index > 0 then
                state.selected_index = 0
                state.search_term = state.search_term .. char
                update_results()
                update_display()
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                vim.api.nvim_command("startinsert")
            else
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                vim.api.nvim_command("startinsert")
                vim.api.nvim_feedkeys(char, 'i', false)
            end
        end

        table.insert(state.buf_keymaps, {mode, lhs})
        vim.keymap.set(mode, lhs, rhs, { buffer = state.buf, nowait = true })
    end

    local function restrict_cursor()
        local cursor = vim.api.nvim_win_get_cursor(state.win)
        local line, col = cursor[1], cursor[2]

        -- second line is index 1 (0-indexed)
        if line == 1 and col < 2 then
            vim.api.nvim_win_set_cursor(state.win, {2, 2})
        end

        -- disable cursor movement in file list
        if line > 1 and state.selected_index == 0 then
            vim.api.nvim_win_set_cursor(state.win, {2, #state.search_term + 2})
        end
    end

    -- autocommand for input handling
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        buffer = state.buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(state.buf, 0, state.header_lines, false)
            if #lines >= state.header_lines then
                local input = lines[state.header_lines]:sub(3) -- remove the "> " prefix
                if input ~= state.search_term then
                    state.search_term = input
                    update_results()
                    update_display()

                    -- keep cursor in search input
                    if state.selected_index == 0 then
                        vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
                    end
                end
            end
        end
    })

    -- autocommand to restrict cursor in search line
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
        buffer = state.buf,
        callback = restrict_cursor
    })

    -- prevent modification of prefix in search line
    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = state.buf,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            if #line < 2 or line:sub(1,2) ~= "> " then
                -- restore prefix if modified
                vim.api.nvim_set_current_line("> " .. state.search_term)
                vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})
            end
        end
    })

    -- initial display
    update_display()
    vim.api.nvim_command("startinsert")
    vim.api.nvim_win_set_cursor(state.win, {state.header_lines, #state.search_term + 2})

    vim.schedule(function()
        local mode_msg = state.mode == "files" and "files" or state.mode == "buffers" and "buffers" or "all files and buffers"
        vim.notify("XPLRR " .. mode_msg .. ": press ctrl+q to exit")
    end)
end

---

-- this xplrr command list
XPLRR.cmd = {
    xplrr = "Xplrr",
    xplrr_all = "XplrrAll",
    xplrr_buffers = "XplrrBuffers",
}

---

-- call xplrr for all (files + buffers) with ignore support
function XPLRR.toggle()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("files")
    end
end

-- call xplrr for files
function XPLRR.toggle_all()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("all")
    end
end

-- call xplrr for buffers
function XPLRR.toggle_buffers()
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        close_window()
    else
        create_window("buffers")
    end
end

---

function XPLRR.setup()
    vim.api.nvim_create_user_command(
        XPLRR.cmd.xplrr,
        XPLRR.toggle,
        {
            desc = "XPLRR: search all files (respects .nvimignore)"
        }
    )
    vim.api.nvim_create_user_command(
        XPLRR.cmd.xplrr_all,
        XPLRR.toggle_all,
        {
            desc = "XPLRR: search all files (including hidden files)"
        }
    )
    vim.api.nvim_create_user_command(
        XPLRR.cmd.xplrr_buffers,
        XPLRR.toggle_buffers,
        {
            desc = "XPLRR: search all opened buffers"
        }
    )
end

---

return XPLRR

