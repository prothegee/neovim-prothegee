local SLR = {}

---

SLR.cmd = {
    seek_look_replace_current_buffer = "SlrBuffer",
    seek_look_replace_current_directory = "SlrDirectory",
    seek_look_replace_in_dir = "SlrInDirectory",
}

---

-- helper to check if a character is a word character
local function is_word_char(char)
    return char:match("[%w_]") ~= nil
end

-- check if a match is exact (word boundaries)
local function is_exact_match(content, start, finish)
    -- check character before match
    if start > 1 then
        local prev_char = content:sub(start - 1, start - 1)
        if is_word_char(prev_char) then
            return false
        end
    end

    -- check character after match
    if finish < #content then
        local next_char = content:sub(finish + 1, finish + 1)
        if is_word_char(next_char) then
            return false
        end
    end

    return true
end

-- count matches with exact match support
local function count_matches(content, search, case_sensitive, exact)
    local count = 0
    local pos = 1
    local len = #content

    while pos <= len do
        local start, finish = content:find(search, pos, true)  -- true for plain text
        if not start then break end

        -- for case-sensitive searches, verify exact case match
        if case_sensitive then
            local matched_text = content:sub(start, finish)
            if matched_text ~= search then
                pos = finish + 1
                goto continue
            end
        end

        -- check if it's an exact match if required
        if not exact or is_exact_match(content, start, finish) then
            count = count + 1
        end

        pos = finish + 1
        ::continue::
    end

    return count
end

-- replace matches with exact match support
local function replace_matches(content, search, replace, case_sensitive, exact)
    local result = {}
    local pos = 1

    while true do
        local start, finish = content:find(search, pos, true)
        if not start then break end

        -- for case-sensitive searches, verify exact case match
        if case_sensitive then
            local matched_text = content:sub(start, finish)
            if matched_text ~= search then
                table.insert(result, content:sub(pos, finish))
                pos = finish + 1
                goto continue
            end
        end

        -- check if it's an exact match if required
        if not exact or is_exact_match(content, start, finish) then
            table.insert(result, content:sub(pos, start - 1))
            table.insert(result, replace)
            pos = finish + 1
        else
            table.insert(result, content:sub(pos, finish))
            pos = finish + 1
        end

        ::continue::
    end

    table.insert(result, content:sub(pos))
    return table.concat(result)
end

-- process files with confirmation
local function process_files(files, search, replace, flags)
    local matches = {}
    local total = 0

    for _, file in ipairs(files) do
        local ok, content = pcall(function()
            local lines = vim.fn.readfile(file, "b")
            return table.concat(lines, "\n")
        end)

        if ok and content then
            local count = count_matches(content, search, flags.sensitive, flags.exact)
            if count > 0 then
                matches[file] = {content = content, count = count}
                total = total + count
            end
        end
    end

    if total == 0 then
        vim.notify("no matches found", vim.log.levels.INFO)
        return
    end

    local message = {"found " .. total .. " occurrences in " .. #vim.tbl_keys(matches) .. " files:"}
    for file, data in pairs(matches) do
        table.insert(message, "  " .. file .. ": " .. data.count)
    end
    vim.notify(table.concat(message, "\n"), vim.log.levels.INFO)

    local choice = vim.fn.confirm("replace all?", "&Yes\n&No", 2)
    if choice ~= 1 then
        vim.notify("operation canceled", vim.log.levels.WARN)
        return
    end

    local processed = 0
    for file, data in pairs(matches) do
        local new_content = replace_matches(data.content, search, replace, flags.sensitive, flags.exact)
        local ok = pcall(function()
            vim.fn.writefile(vim.split(new_content, "\n"), file, "b")
        end)
        if ok then
            processed = processed + 1
        end
    end

    vim.notify("replaced in " .. processed .. " files", vim.log.levels.INFO)
end

-- parse command arguments
local function parse_args(fargs)
    local flags = { sensitive = false, exact = false, dir = nil }
    local search, replace
    local i = 1

    -- parse flags first
    while i <= #fargs do
        local arg = fargs[i]
        if arg == "--sensitive" then
            flags.sensitive = true
            i = i + 1
        elseif arg == "--match" then
            flags.exact = true
            i = i + 1
        elseif arg == "--dir" then
            i = i + 1
            flags.dir = fargs[i]
            i = i + 1
        else
            break
        end
    end

    -- get search and replace terms
    if i <= #fargs then search = fargs[i] end
    if i + 1 <= #fargs then replace = fargs[i + 1] end

    if not search or not replace then
        return nil, "missing search or replace terms"
    end

    -- remove surrounding quotes but preserve escaped characters
    search = search:gsub("^['\"](.*)['\"]$", "%1")
    replace = replace:gsub("^['\"](.*)['\"]$", "%1")

    -- handle escaped characters
    search = search:gsub("\\(.)", "%1")
    replace = replace:gsub("\\(.)", "%1")

    return {
        search = search,
        replace = replace,
        flags = flags
    }
end

---

function SLR.setup()
    -- SlrBuffer: current buffer
    vim.api.nvim_create_user_command(SLR.cmd.seek_look_replace_current_buffer, function(opts)
        local args, err = parse_args(opts.fargs)
        if not args then
            vim.notify("error: " .. err, vim.log.levels.ERROR)
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")

        local count = count_matches(content, args.search, args.flags.sensitive, args.flags.exact)
        if count == 0 then
            vim.notify("no matches found", vim.log.levels.INFO)
            return
        end

        vim.notify("found " .. count .. " occurrences", vim.log.levels.INFO)
        local choice = vim.fn.confirm("replace all?", "&Yes\n&No", 2)
        if choice ~= 1 then
            vim.notify("operation canceled", vim.log.levels.WARN)
            return
        end

        local new_content = replace_matches(content, args.search, args.replace, args.flags.sensitive, args.flags.exact)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, vim.split(new_content, "\n"))
        vim.notify("replacement completed", vim.log.levels.INFO)
    end, { nargs = "*" })

    -- SlrDirectory: current directory
    vim.api.nvim_create_user_command(SLR.cmd.seek_look_replace_current_directory, function(opts)
        local args, err = parse_args(opts.fargs)
        if not args then
            vim.notify("error: " .. err, vim.log.levels.ERROR)
            return
        end

        local dir = vim.fn.getcwd()
        local files = vim.fn.globpath(dir, "**", false, true)
        process_files(files, args.search, args.replace, args.flags)
    end, { nargs = "*" })

    -- SlrInDirectory: specified directory
    vim.api.nvim_create_user_command(SLR.cmd.seek_look_replace_in_dir, function(opts)
        local args, err = parse_args(opts.fargs)
        if not args then
            vim.notify("error: " .. err, vim.log.levels.ERROR)
            return
        end

        if not args.flags.dir then
            vim.notify("error: missing --dir argument", vim.log.levels.ERROR)
            return
        end

        if vim.fn.isdirectory(args.flags.dir) == 0 then
            vim.notify("error: invalid directory: " .. args.flags.dir, vim.log.levels.ERROR)
            return
        end

        local files = vim.fn.globpath(args.flags.dir, "**", false, true)
        process_files(files, args.search, args.replace, args.flags)
    end, { nargs = "*" })
end

return SLR
