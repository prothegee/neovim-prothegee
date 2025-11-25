-- get active lsp
_G.get_active_lsp = function()
    local clients = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(clients, client.name)
    end
    if #clients > 0 then
        return "" .. table.concat(clients, ", ") .. " "
    end
    return "n/a "
end

-- get active mode
_G.get_active_current_mode = function()
    local mode_map = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        [""] = "V-BLOCK",  -- Ctrl-V
        c = "COMMAND",
        s = "SELECT",
        S = "S-LINE",
        [""] = "S-BLOCK",
        t = "TERMINAL",
        R = "REPLACE",
        ["!"] = "SHELL",
        r = "PROMPT",
    }
    local mode_code = vim.api.nvim_get_mode().mode
    return mode_map[mode_code] or string.upper(mode_code)
end

-- get dianostic hint
_G.get_diagnostic_hint = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.HINT then
            total = total + 1
        end
    end

    return total
end

-- get dianostic info
_G.get_diagnostic_info = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.INFO then
            total = total + 1
        end
    end

    return total
end

-- get dianostic warn
_G.get_diagnostic_warn = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.WARN then
            total = total + 1
        end
    end

    return total
end

-- get dianostic error
_G.get_diagnostic_error = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.ERROR then
            total = total + 1
        end
    end

    return total
end

--  

-- get current work dir with the file buffer
_G.get_cwd_and_file_buffer = function()
    local buf_name = vim.api.nvim_buf_get_name(0)

    if buf_name == "" then
        return "n/a"
    end

    -- using cwd of vim.fn.getcwd() make full path
    local relative_path = vim.fn.fnamemodify(buf_name, ":.")

    if relative_path == buf_name then
        relative_path = vim.fn.fnamemodify(buf_name, ":t")
    end

    return relative_path
end

-- --------------------------------------------------------- --
-- --------------------------------------------------------- --


--[[
-- completion was triggered by typing an identifier (24x7 code
-- complete), manual invocation (e.g ctrl+space) or via api.
1:invoked
    - currently for function:
        - fullfil for the available params, but can't return & change for the param/s

-- completion was triggered by a trigger character specified by
-- the `triggercharacters` properties of the `completionregistrationoptions`.
2:triggercharacter
    - currently for function:
        - not fullfil for the available params

-- completion was re-triggered as the current completion list is incomplete.
3:triggerforincompletecompletions
    - currently for function:
        - fullfil for the available params, but can't return & change for the param/s
--]]
local TRIGGER_KIND = 3

--[[
for completion and snippet

@param findstart
@param base
--]]
_G.prt_fuzzy_completion = function(findstart, _)
    if vim.fn.mode() ~= "i" then
        if findstart == 1 then
            return -1
        else
            return {}
        end
    end

    local _prt = {
        _snippets = require"nvim-prt.snppts"
    }

    local buf, line, line_text, row, col, cursor, start_char, end_char

    if findstart == 1 then
        line = vim.fn.getline(".")
        col = vim.fn.getcol(".")
        return (line:sub(1, col):find("[%w_]*$") or col) - 1
    else
        buf = vim.api.nvim_get_current_buf()

        -- validate buffer
        if not vim.api.nvim_buf_is_valid(buf) or vim.fn.mode() ~= "i" then
            return {}
        end

        -- state current buffer
        local current_buf = buf

        cursor = vim.api.nvim_win_get_cursor(0)
        row, col = cursor[1] - 1, cursor[2]
        line_text = vim.fn.getline(".")

        -- initial word boundaries
        start_char = (line_text:sub(1, col):find("[%w_]*$") or col) - 1
        end_char = col

        -- specified case?

        -- process text doc completion
        vim.lsp.buf_request(buf, "textDocument/completion", {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = { line = row, character = col },
            context = { triggerKind = TRIGGER_KIND },
        }, function(err, result, _)
            -- validate state buf first
            if not vim.api.nvim_buf_is_valid(current_buf) or vim.api.nvim_get_current_buf() ~= current_buf or vim.fn.mode() ~= "i" then
                return
            end

            if err or not result then
                -- vim.print("cmpltn: error nor result") -- ignore tmp print
                return
            end

            local items = result.items or result

            if not items then
                -- vim.print("cmpltn: items is empty") -- ignore tmp print
                return
            end

            local label
            local all_matches = {}
            local lsp_matches = {}
            local snippet_matches = {}

            for _, item in ipairs(items) do
                label = item.textEdit and item.textEdit.newText or item.label

                local kind_char, kind_text = "", ""

                if item.kind then
                    kind_text = vim.lsp.protocol.CompletionItemKind[item.kind] or ""
                    kind_char = kind_text:sub(1, 1):lower()
                end

                -- default word boundaries 0-based
                local default_start = start_char
                local default_end = end_char

                -- skip determine replacement range
                local item_start, item_end

                -- skip use lsp textEdit range if available
                if item.textEdit and item.textEdit.range then
                    item_start = item.textEdit.range.start.character
                    item_end = item.textEdit.range["end"].character
                else
                    item_start = default_start
                    item_end = default_end
                end

                -- ensure nil not pass?
                if type(item_start) ~= "number" then item_start = default_start end
                if type(item_end) ~= "number" then item_end = default_end end

                -- clamp valid range
                item_start = math.max(0, item_start)
                item_end = math.min(#line_text, item_end)

                local clean_label = label:gsub("%b().*", "")

                -- update data match
                table.insert(lsp_matches, {
                    word = clean_label,
                    abbr = clean_label,
                    kind = kind_char,
                    menu = kind_text,
                    info = item.documentation and (
                        type(item.documentation) == "string" and item.documentation or (item.documentation.value or "")
                    ) or "",
                    icase = 1,
                    dup = 1,
                    user_data = {
                        start_char = item_start,
                        end_char =  item_end
                    }
                })
            end

            local all_snippets = _prt._snippets.get_all_snippets_for_filetype()

            for _, snippet in ipairs(all_snippets) do
                if type(snippet) == "table" and type(snippet.trigger) == "string" and type(snippet.body) == "table" then
                    local body = table.concat(snippet.body, "\n")

                    local trigger = snippet.trigger
                    local description = snippet.description or "Snippet"

                    table.insert(snippet_matches, {
                        word = trigger,
                        abbr = trigger,
                        kind = "s",
                        menu = description,
                        info = body,
                        icase = 1,
                        dup = 1,
                        user_data = vim.json.encode({
                            start_char = start_char,
                            end_char = end_char,
                            is_snippet = true,
                            snippet_body = snippet.body
                        })
                    })
                end
            end

            -- final extend to all match & merge
            all_matches = vim.list_extend(all_matches, lsp_matches)
            all_matches = vim.list_extend(all_matches, snippet_matches)

            -- finished with validate
            if vim.api.nvim_get_current_buf() == current_buf and vim.fn.mode() == "i" then
                vim.fn.complete(start_char + 1, all_matches)
            end
        end)

        return {}
    end
end

-- --------------------------------------------------------- --
-- --------------------------------------------------------- --

