local CMPLTN = {}
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

local COMPLETION_DELAY = 150 -- in milliseconds

---

local _buf_default_completion = function(buffer)
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
    vim.opt.shortmess:append("c")
    vim.opt.wildmode = "longest:full,full"
    vim.opt.wildignorecase = true

    -- completion using default
    -- vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- completion using nvim-prt.cmpltn
    vim.bo[buffer].omnifunc = "v:lua._prt_fuzzy_completion(0, '')"
end

local _completion_trigger = function(client, buffer)
    _buf_default_completion(buffer)

    -- manual added using ctrl+space in insert-mode
    vim.api.nvim_buf_set_keymap(buffer,
        "i", "<C-space>",
        -- "<C-x><C-o>",
        "<cmd>call v:lua._prt_fuzzy_completion(0, '')<CR>",
        {
            desc = "prt auto completion manual trigger",
            silent = true,
            noremap = true
        }
    )
end

local function _get_file_completions()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    local before_cursor = line:sub(1, col + 1)
    local path_match = before_cursor:match("([%w%._/\\%-]*)$")

    if not path_match or path_match == "" then
        return {}
    end

    local dir_part = vim.fn.fnamemodify(path_match, ":h")
    local file_part = vim.fn.fnamemodify(path_match, ":t")

    if dir_part == "" then
        dir_part = "."
    end

    dir_part = vim.fn.resolve(dir_part)

    if vim.fn.isdirectory(dir_part) == 0 then
        return {}
    end

    local glob_pattern = dir_part .. (dir_part:match("[/\\]$") and "*" or "/*")
    local entries = vim.fn.glob(glob_pattern, true, true)

    local matches = {}
    local seen = {}

    for _, full_path in ipairs(entries) do
        local fname = vim.fn.fnamemodify(full_path, ":t")

        if vim.startswith(fname, file_part) then
            if seen[fname] then goto continue end
            seen[fname] = true

            local is_dir = vim.fn.isdirectory(full_path) == 1
            local kind_char = is_dir and "d" or "f"
            local kind_text = is_dir and "Directory" or "File"

            local display_path = full_path
            if vim.startswith(full_path, vim.fn.getcwd()) then
                display_path = vim.fn.fnamemodify(full_path, ":.")
            end

            local start_char = col - #file_part + 1
            local end_char = col + 1

            table.insert(matches, {
                word = fname .. (is_dir and "/" or ""),
                abbr = display_path,
                kind = kind_char,
                menu = kind_text,
                info = full_path,
                icase = 1,
                dup = 0,
                user_data = {
                    start_char = start_char - 1,
                    end_char = end_char - 1
                }
            })
            ::continue::
        end
    end

    return matches
end

local function _get_line_completions()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    local before_cursor = line:sub(1, col + 1)
    local query = before_cursor:match("[%w_]*$") or ""

    if query == "" then
        return {}
    end

    local matches = {}
    local seen = {}
    local start_char = col - #query + 1
    local end_char = col + 1

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if not vim.api.nvim_buf_is_valid(bufnr) then
            goto continue_buf
        end

        if bufnr == vim.api.nvim_get_current_buf() then
            goto continue_buf
        end

        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        if buftype ~= "" then
            goto continue_buf
        end

        local lines
        local was_loaded = vim.api.nvim_buf_is_loaded(bufnr)

        if not was_loaded then
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname == "" then
                goto continue_buf
            end

            local ok = pcall(function()
                vim.cmd("silent noautocmd keepalt buffer " .. bufnr)
            end)

            if not ok or not vim.api.nvim_buf_is_loaded(bufnr) then
                goto continue_buf
            end

            lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

            pcall(function()
                vim.cmd("silent noautocmd bunload " .. bufnr)
            end)
        else
            lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        end

        if not lines then
            goto continue_buf
        end

        for _, candidate in ipairs(lines) do
            --[[
            NOTE:
                - find if candidate contains query as a prefix to a word
                - match does any word in candidate begin with query
                - the original <C-x><C-l> matches from the beginning of the line
                - look for the first word that matches
            --]]
            for word in candidate:gmatch("[%w_]+") do
                if vim.startswith(word, query) and not seen[word] then
                    seen[word] = true
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    local info = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or ("Buf " .. bufnr)

                    table.insert(matches, {
                        word = word,
                        abbr = word,
                        kind = "l",
                        menu = "Line",
                        info = info,
                        icase = 1,
                        dup = 0,
                        user_data = {
                            start_char = start_char - 1,
                            end_char = end_char - 1
                        }
                    })
                    break -- 1 match /line
                end
            end
        end

        ::continue_buf::
    end

    return matches
end

local function _handle_complete_done()
    --[[
    MAYBE:
    CompleteDone:
    - required to store state of how many $n and store it
    - if $n available, highlight it, and editit,
    - pressing tab, will move to the next $n until $n is out of range
    --]]

    local data = vim.v.completed_item
    if vim.tbl_isempty(data) or not data.user_data then
        return
    end

    -- error:
    -- - caused error when insert is force, on:
    --  - json file
    local user_data = type(data.user_data) == "string" and vim.json.decode(data.user_data) or data.user_data

    if not user_data.is_snippet or not user_data.snippet_body then
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    local start_col = user_data.start_char
    local end_col = col  -- current cursor

    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]

    local body_lines = user_data.snippet_body
    if #body_lines == 0 then
        return
    end

    -- use inline if just 1 line
    if #body_lines == 1 then
        local new_line = line:sub(1, start_col) .. body_lines[1] .. line:sub(end_col + 1)
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
        -- Sesuaikan kursor ke akhir baris baru (opsional)
        local new_cursor_col = start_col + #body_lines[1]
        vim.api.nvim_win_set_cursor(0, { row + 1, new_cursor_col })
    else
        local before = line:sub(1, start_col)
        local after = line:sub(end_col + 1)

        local first_line = before .. body_lines[1]
        local last_line = body_lines[#body_lines] .. after

        local new_lines = { first_line }
        for i = 2, #body_lines - 1 do
            table.insert(new_lines, body_lines[i])
        end
        if #body_lines > 1 then
            table.insert(new_lines, last_line)
        end

        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, new_lines)

        vim.api.nvim_win_set_cursor(0, { row + 1, #first_line })
    end
end

---

--[[
TODO:
- DO NOT USE ANY PLUGINS!
- integrate with nvim-prt.snppts
- async, body completion should be expand from:
    - <C-x><C-o>
    - nvim-prt.snppts
- if there are any parameters of $n (n is number):
    - store it before expand
NOTE:
- call complete with params, i.e.: my_func(${1:param})
    label:gsub("%b()", "")

- call compelte without params, i.e.: my_func
label:gsub("%b().*", "")
FATAL:
- when something pop up from list, and if there's another buffer opened,
    side by side in any position, it will close current buffer
    and change active buffer to the other buffer
--]]
_G._prt_fuzzy_completion = function(findstart, base)
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
        cursor = vim.api.nvim_win_get_cursor(0)
        row, col = cursor[1] - 1, cursor[2]
        line_text = vim.fn.getline(".")

        -- initial word boundaries
        start_char = (line_text:sub(1, col):find("[%w_]*$") or col) - 1
        end_char = col

        -- process text doc completion
        vim.lsp.buf_request(buf, "textDocument/completion", {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = { line = row, character = col },
            context = { triggerKind = TRIGGER_KIND },
        }, function(err, result, context)
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
            local file_matches = {}
            local line_matches = {}
            local snippet_matches = {}

            -- completion lsp, file, & line
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
            -- TODO: add custom snippets from _prt.snppts
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

            -- matches completion & merge
            file_matches = _get_file_completions()
            line_matches = _get_line_completions()

            -- final extend to all match & merge
            all_matches = vim.list_extend(lsp_matches, file_matches)
            all_matches = vim.list_extend(all_matches, line_matches)
            all_matches = vim.list_extend(all_matches, snippet_matches)

            -- finished
            vim.fn.complete(start_char + 1, all_matches)
        end)

        return {}
    end
end

---

-- default capabilities
CMPLTN.capabilities = vim.lsp.protocol.make_client_capabilities()
-- CMPLTN.capabilities.textDocument = {
--     completion = {
--         contextsupport = true,
--         dynamicregistration = true,
--         completionitem = {
--             -- tagsupport = { valueset = { 1 } },
--             -- snippetsupport = true,
--             resolvesupport = {
--                 properties = { "detail", "documentation", "additionalTextEdits", "snippets" }
--             },
--             -- preselectsupport = true,
--             -- deprecatedsupport = true,
--             -- labeldetailssupport = true,
--             documentationformat = { "markdown", "plaintext" },
--             -- insertreplacesupport = true,
--             -- inserttextmodesupport = {
--             --     valueset = { 1, 2 }
--             -- },
--             -- commitcharacterssupport = true,
--         }
--     },
--     diagnostic = {
--         dynamicRegistration = true
--     },
--     inlineCompletion = { dynamicRegistration = true }
-- }
-- CMPLTN.capabilities.workspace = {
--     diagnostics = { refreshSupport = true }
-- }


---

-- on init
function CMPLTN.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semantictokensprovider = nil
    end
end

-- on attach
function CMPLTN.on_attach(client, buffer)
    _completion_trigger(client, buffer)
end

---

-- default completion
function CMPLTN.default_completion(buffer)
    _buf_default_completion(buffer)
end

-- # default auto command
-- ---
-- # note
-- * will reject if current server not supported from supported_lsps param
function CMPLTN.default_autocmd(supported_lsps)
    local _prt = {
        nvim = require"nvim-prt.tools.nvim"
    }

    local rejected = true

    if next(supported_lsps) then
        for _, lsp in pairs(supported_lsps) do
            if lsp == _prt.nvim.get_current_lsp_server_name() then
                rejected = false
                break
            end
        end
    end

    -- BufEnter
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function(args)
            if rejected then return end

            local buffer = args.buf

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            CMPLTN.default_completion(buffer)
        end
    })
    -- LspAttach
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            if rejected then return end

            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            CMPLTN.on_attach(client, buffer)
        end
    })
    -- InsertCharPre
    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = function(args)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.bo[buffer].omnifunc ~= "" and vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        -- "<C-x><C-o>",
                        "<cmd>call v:lua._prt_fuzzy_completion(0, '')<CR>",
                        true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
    -- TextChangedI
    vim.api.nvim_create_autocmd("TextChangedI", {
        callback = function(args)
            if rejected then return end

            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        -- "<C-x><C-o>",
                        "<cmd>call v:lua._prt_fuzzy_completion(0, '')<CR>",
                        true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
    -- CompleteDone
    vim.api.nvim_create_autocmd("CompleteDone", {
        pattern = "*",
        callback = _handle_complete_done
    })
end

---

return CMPLTN

