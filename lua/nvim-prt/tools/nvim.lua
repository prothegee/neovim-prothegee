local NVIM = {}

---

NVIM.os = {
    windows = vim.fn.has"win32" == 1 or vim.fn.has"win64" == 1
}

---

-- # initialize .nvim
function NVIM.initialize()
    local target = vim.fn.getcwd() .. "/.nvim"

    if vim.fn.isdirectory(target) == 0 then
        vim.fn.mkdir(target, "p")
    end
end

function NVIM.create_terminal(command, message_ok, message_error, height_percentage)
    height_percentage = height_percentage or 0.3

    -- Create new buffer
    local buf = vim.api.nvim_create_buf(false, false)

    -- Open terminal at bottom of current window
    vim.cmd("botright split")
    local win = vim.api.nvim_get_current_win()

    -- Get total available height (excluding statusline, etc.)
    local total_height = vim.o.lines - vim.o.cmdheight
    if vim.o.laststatus > 0 then
        total_height = total_height - 1
    end

    -- Calculate and set window height
    local split_height = math.floor(total_height * height_percentage)
    vim.api.nvim_win_set_height(win, split_height)

    -- Set buffer to window
    vim.api.nvim_win_set_buf(win, buf)

    -- Set buffer options
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "terminal", { buf = buf })

    -- Create terminal instance
    local channel = vim.api.nvim_open_term(buf, {})

    -- Run command with job control
    local job_id = vim.fn.jobstart(command, {
        pty = true,
        on_stdout = function(_, data, _)
            for _, d in ipairs(data) do
                vim.api.nvim_chan_send(channel, d .. "\r\n")
            end
        end,
        on_exit = function(_, exit_code, _)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(buf) then return end

                local status = (exit_code == 0)
                    and (message_ok or "completed successfully")
                    or (message_error or ("failed with code " .. exit_code))

                vim.api.nvim_chan_send(channel, "\r\n" .. status .. "\r\n---\r\nINFO: press ctrl+q to exit")

                -- Move to end of buffer
                vim.api.nvim_command("normal! G")

                -- Close buffer automatically after delay
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end, 3000)

                local notification_level = (exit_code == 0)
                    and vim.log.levels.INFO
                    or vim.log.levels.ERROR

                vim.notify(status, notification_level)
            end)
        end
    })

    -- Set keymaps for quick exit
    vim.keymap.set("n", "<C-q>", function()
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, silent = true })

    vim.keymap.set("t", "<C-q>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, silent = true })

    vim.keymap.set("i", "<C-q>", function()
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, silent = true })

    vim.notify("INFO: press ctrl+q to exit", vim.log.levels.INFO)

    return {
        buf = buf,
        win = win,
        job_id = job_id
    }
end

-- # create terminal
-- ---
-- # params
-- * @param command {string} - command object to pass
-- * @param title {string} - terminal title
-- * @param width_percentage {number} - range from 0.0 to 1.0 of total width active editor
-- * @param height_percentage {number} - range from 0.0 to 1.0 of total height active editor
-- * @param listed_buf {boolean} - sign the terminal as listed buf or not (false for unlisted)
-- * @param style {string} - floating window style
-- * @param border {string} - floating window border
-- * @param title_pos {string} - floating window title position
-- ---
-- # return
-- window object
function NVIM.create_floating_terminal(command, title,
                                       width_percentage,
                                       height_percentage,
                                       listed_buf,
                                       style,
                                       border,
                                       title_pos)
    local buf = vim.api.nvim_create_buf(false, listed_buf)

    -- Calculate dimensions
    local width = math.floor(vim.o.columns * (width_percentage or 0.8))
    local height = math.floor(vim.o.lines * (height_percentage or 0.8))

    local window = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = style or "minimal",
        border = border or "rounded",
        title = title,
        title_pos = title_pos or "center"
    })

    -- Set buffer options
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "terminal", { buf = buf })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })

    -- Prevent editing in floating terminal
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "<NOP>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "i", "<CR>", "<NOP>", { noremap = true, silent = true })

    -- Run command in terminal
    local job_id = vim.fn.jobstart(command, {
        pty = true,
        on_stdout = function(_, data, _)
            if vim.api.nvim_buf_is_valid(buf) then
                -- Append output to buffer
                local lines = {}
                for _, d in ipairs(data) do
                    if d ~= "" then
                        table.insert(lines, d)
                    end
                end
                if #lines > 0 then
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
                end
            end
        end,
        on_exit = function(_, code, _)
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                    "",
                    "process exited with code: " .. code,
                    "INFO: press ctrl+q to exit"
                })

                -- Auto-close after delay
                vim.defer_fn(function()
                    if vim.api.nvim_win_is_valid(window) then
                        vim.api.nvim_win_close(window, true)
                    end
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end, 3000)
            end
        end
    })

    -- Set keymaps for quick exit
    vim.keymap.set("n", "<C-q>", function()
        if vim.api.nvim_win_is_valid(window) then
            vim.api.nvim_win_close(window, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, silent = true })

    vim.keymap.set("i", "<C-q>", function()
        if vim.api.nvim_win_is_valid(window) then
            vim.api.nvim_win_close(window, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf, silent = true })

    vim.notify("INFO: press ctrl+q to exit", vim.log.levels.INFO)

    return window
end

---

return NVIM
