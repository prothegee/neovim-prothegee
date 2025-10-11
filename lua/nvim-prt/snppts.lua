local SNPPTS = {}

---

-- initialize snippets table
SNPPTS.snippets = {}

---

-- lua snippet
SNPPTS.snippets.lua = require"nvim-prt.snippets.lua"
-- todo: c snippet
SNPPTS.snippets.c = require"nvim-prt.snippets.c"
-- todo: cpp snippet
SNPPTS.snippets.cpp = require"nvim-prt.snippets.cpp"
-- todo: cmake snippet
-- todo: rust snippet
-- todo: go snippet
-- todo: javascript snippet
-- todo: svelte snippet
-- todo: html

---

local function expand_snippet_with_info(info)
    local row = info.row
    local start_col = info.start_col
    local col = info.col
    local snippet = info.snippet
    local post_text = info.post_text
    local indent = info.indent

    -- prep for snippet lines with proper indent
    local lines = vim.split(snippet, "\n")
    local processed_lines = {}

    -- first line doesn't get extra indentation
    table.insert(processed_lines, lines[1])

    -- subsequence of ident
    for i = 2, #lines do
        table.insert(processed_lines, indent .. lines[i])
    end

    -- replace trigger with snippet
    vim.api.nvim_buf_set_text(0, row, start_col, row, col, {processed_lines[1]})

    -- insert remain lines, otherwise handle single line snippets
    if #processed_lines > 1 then
        -- append post_text to last line
        processed_lines[#processed_lines] = processed_lines[#processed_lines] .. post_text

        local remaining_lines = {}

        for i = 2, #processed_lines do
            table.insert(remaining_lines, processed_lines[i])
        end

        vim.api.nvim_buf_set_lines(0, row + 1, row + 1, false, remaining_lines)
    else
        vim.api.nvim_buf_set_text(0, row, #processed_lines[1] + start_col,
                                  row, #processed_lines[1] + start_col, {post_text})
    end

    -- pos cursor at end of snippet
    local new_row = row + #processed_lines - 1
    local new_col = #processed_lines[#processed_lines] - #post_text

    vim.api.nvim_win_set_cursor(0, {new_row + 1, new_col})
end

local function get_snippet_info()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    local line = vim.api.nvim_get_current_line()

    -- current indentation
    local indent = line:match("^%s*") or ""

    -- extract trigger word before cursor
    local start_col = col
    while start_col > 0 and line:sub(start_col, start_col):match("[%w_]") do
        start_col = start_col - 1
    end

    local trigger = line:sub(start_col + 1, col)
    if trigger == "" then return nil end

    -- snippet for current filetype
    local ft = vim.bo.filetype
    local snippet = (SNPPTS.snippets[ft] or {})[trigger] or ""
    if snippet == "" then return nil end

    return {
        row = row,
        col = col,
        start_col = start_col,
        snippet = snippet,
        post_text = line:sub(col + 1),
        indent = indent
    }
end

---

function SNPPTS.get_snippet(trigger)
    local ft = vim.bo.filetype
    return (SNPPTS.snippets[ft] or {})[trigger]
end

function SNPPTS.get_snippets()
    local ft = vim.bo.filetype
    return SNPPTS.snippets[ft] or {}
end

function SNPPTS.get_completion_items()
    local ft = vim.bo.filetype
    local snippets = SNPPTS.snippets[ft] or {}
    local items = {}

    for trigger, snippet in pairs(snippets) do
        table.insert(items, {
            word = trigger,
            menu = "Snippet^",
            info = snippet:gsub("\n", "  "):sub(1, 100),
            kind = "s"
        })
    end

    return items
end

function SNPPTS.expand_snippet()
    local info = get_snippet_info()
    if not info then return false end

    -- schedule buffer modifications for safe execution
    vim.schedule(function()
        expand_snippet_with_info(info)
    end)

    return true
end

---

return SNPPTS
