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
local TRIGGER_KIND = 2

local COMPLETION_DELAY = 150 -- in milliseconds

---

-- custom omnifunc for fuzzy completion
--[[
TODO:
- this completion also need to find all param that available from function args, i.e.:
    - when there's available function like in c/c++, says `void say_your_name(const char* name)`
    - but when it completed (if TRIGGER_KIND ~= 2), it become `say_your_name(${1:const char *name})`, the problem are:
        - active cursor end-up in last of completed function call
        - can't change first what ever param
        - it should be able to change the available list on param when press tab by default
    - see TRIGGER_KIND for which one will suits
--]]
_G._fuzzy_completion_omnifunc = function(findstart, base)
    local _snippet = require"nvim-prt.snppts"

    if findstart == 1 then
        local line = vim.fn.getline(".")
        local col = vim.fn.col(".")
        return (line:sub(1, col):find("[%w_]*$") or col) - 1
    else
        local buf = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1] - 1, cursor[2]
        local line_text = vim.fn.getline(".")

        -- calculate initial word boundaries
        local start_char = (line_text:sub(1, col):find("[%w_]*$") or col) - 1
        local end_char = col

        vim.lsp.buf_request(buf, "textDocument/completion", {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = { line = row, character = col },
            context = { triggerKind = TRIGGER_KIND },
        }, function(err, result, _)
            if err or not result then return end

            local items = result.items or result
            if not items then return end

            local matches = {}
            local base_lower = base:lower()
            local custom_items = {}

            -- add custom snippets
            for trigger, snippet in pairs(_snippet.get_snippets()) do
                if trigger:lower():find(base_lower, 1, true) then
                    table.insert(custom_items, {
                        word = trigger,
                        abbr = trigger,
                        kind = "s",
                        menu = "Snippet: " .. snippet:gsub("\n", " "):sub(1, 50),
                        info = snippet,
                        icase = 1,
                        dup = 1,
                        user_data = {
                            is_snippet = true,
                            start_char = start_char,
                            end_char = start_char + #trigger
                        }
                    })
                end
            end

            -- process LSP completion items
            for _, item in ipairs(items) do
                local label = item.textEdit and item.textEdit.newText or item.label
                if label and label:lower():find(base_lower, 1, true) then
                    -- Get completion kind info
                    local kind_char = ""
                    local kind_text = ""
                    if item.kind then
                        kind_text = vim.lsp.protocol.CompletionItemKind[item.kind] or ""
                        kind_char = kind_text:sub(1, 1):lower()
                    end

                    -- determine replacement range
                    local item_start = start_char
                    local item_end = end_char
                    local word = label

                    -- use LSP's textEdit range if available
                    if item.textEdit and item.textEdit.range then
                        item_start = item.textEdit.range.start.character
                        item_end = item.textEdit.range["end"].character
                        word = item.textEdit.newText
                    end

                    -- validate ranges
                    item_start = math.max(0, item_start)
                    item_end = math.min(#line_text, item_end)

                    table.insert(matches, {
                        word = word,
                        abbr = label:gsub("%b()", ""),
                        kind = kind_char,
                        menu = kind_text,
                        info = item.documentation and (
                            type(item.documentation) == "string" and item.documentation or
                            (item.documentation.value or "")
                        ) or "",
                        icase = 1,
                        dup = 1,
                        user_data = {
                            start_char = item_start,
                            end_char = item_end
                        }
                    })
                end
            end

            -- add custom snippets to matches
            for _, item in ipairs(custom_items) do
                table.insert(matches, item)
            end

            -- trigger completion with initial start position
            vim.fn.complete(start_char + 1, matches)
        end)

        return {}
    end
end

---

local _buf_default_completion = function(buffer)
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
    vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- vim.bo[buffer].omnifunc = "v:lua._fuzzy_completion_omnifunc"
end

local _completion_trigger = function(client, buffer)
    vim.opt.shortmess:append("c")
    _buf_default_completion(buffer)

    vim.api.nvim_buf_set_keymap(
        buffer,
        "i", "<C-space>",
        "<cmd>call v:lua._fuzzy_completion_omnifunc(0, '')<CR>",
        {
            desc = "internal: auto completion trigger",
            silent = true,
            noremap = true
        }
    )
end

---

-- default capabilities
CMPLTN.capabilities = vim.lsp.protocol.make_client_capabilities()
CMPLTN.capabilities.textDocument.completion = {
    contextsupport = true,
    dynamicregistration = true,
    completionitem = {
        tagsupport = { valueset = { 1 } },
        snippetsupport = true,
        resolvesupport = {
            properties = { "detail", "documentation", "additionalTextEdits", "snippets" }
        },
        preselectsupport = true,
        deprecatedsupport = true,
        labeldetailssupport = true,
        documentationformat = { "markdown", "plaintext" },
        insertreplacesupport = true,
        inserttextmodesupport = {
            valueset = { 1, 2 }
        },
        commitcharacterssupport = true,
    },
}

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
    local _snippet = require"nvim-prt.snppts"

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
            local buffer_name = vim.fn.expand("%")

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
                        "<C-x><C-o>",
                        -- "<cmd>call v:lua._fuzzy_completion_omnifunc(0, '')<CR>",
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
                        "<C-x><C-o>",
                        -- "<cmd>call v:lua._fuzzy_completion_omnifunc(0, '')<CR>",
                        true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
    -- CompleteDone
    vim.api.nvim_create_autocmd("CompleteDone", {
        pattern = "*",
        callback = function()
            local completed_item = vim.v.completed_item
            if not completed_item or not completed_item.user_data then
                return
            end

            local start_char = completed_item.user_data.start_char
            local end_char = completed_item.user_data.end_char

            -- handle snippet expansion
            if completed_item.user_data.is_snippet then
                local trigger = completed_item.word
                local snippet = _snippet.get_snippet(trigger)
                if not snippet then return end

                local cursor = vim.api.nvim_win_get_cursor(0)
                local row = cursor[1] - 1
                local line = vim.api.nvim_get_current_line()
                local indent = line:match("^%s*") or ""
                local post_text = line:sub(end_char + 1)

                -- apply snippet with proper indentation
                local lines = vim.split(snippet, "\n")
                if #lines > 0 then
                    lines[#lines] = lines[#lines] .. post_text
                end
                if #lines > 1 then
                    for i = 2, #lines do
                        lines[i] = indent .. lines[i]
                    end
                end

                -- replace trigger with snippet
                vim.api.nvim_buf_set_text(0, row, start_char, row, end_char, lines)

                -- position cursor at first placeholder
                local target_row = row
                local target_col = 0
                for i, l in ipairs(lines) do
                    local pos = l:find("%$1")
                    if pos then
                        target_row = row + i - 1
                        target_col = pos - 1
                        break
                    end
                end
                vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col })
            end
        end,
    })
end

---

return CMPLTN
