local CAPABILITIES = {}

---

-- local TRIGGER_KIND = 3
local COMPLETION_DELAY = 60

local OMNIFUNC = {
    DEFAULT = "v:lua.vim.lsp.omnifunc",
    PRT_FUZZY_COMPLETION = "v:lua.prt_fuzzy_completion(0, '')"
}
local OMNIFUNC_CALLBACK = {
    DEFAULT = "<C-x><C-o>",
    PRT_FUZZY_COMPLETION = "<cmd>call v:lua.prt_fuzzy_completion(0, '')<CR>"
}

---

--[[
MAYBE:
CompleteDone:
- required to store state of how many $n and store it
- if $n available, highlight it, and editit,
- pressing tab, will move to the next $n until $n is out of range
--]]
local function _handle_complete_done()
    local data = vim.v.completed_item
    if vim.tbl_isempty(data) or not data.user_data then
        return
    end

    local user_data = data.user_data

    -- if user_data is a string, it might be json encoded snippet data
    if type(user_data) == "string" then
        if user_data == "" then
            return
        end

        local ok, decoded = pcall(vim.json.decode, user_data)

        if not ok or type(decoded) ~= "table" then
            return
        end

        user_data = decoded
    elseif type(user_data) ~= "table" then
        return
    else
        vim.print("warning: not string nor table")
        return
    end

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
        -- match cursor to end of new line
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

-- default capabilities
CAPABILITIES.capabilities = vim.lsp.protocol.make_client_capabilities()
CAPABILITIES.capabilities.textDocument = {
    completion = {
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
        }
    },
    diagnostic = {
        dynamicRegistration = true
    },
    inlineCompletion = { dynamicRegistration = true }
}
CAPABILITIES.capabilities.workspace = {
    diagnostics = { refreshSupport = true }
}

---
---

-- @brief default completion
--
-- @param buffer - as buffer
local _default_completion = function(buffer)
    vim.wildmode = "longest:full, full"
    vim.opt.shortmess:append("c")
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
    vim.opt.wildignorecase = true

    -- default
    vim.bo[buffer].omnifunc = OMNIFUNC.PRT_FUZZY_COMPLETION
end

---

-- @brief default completion
--
-- @param _ - as client
-- @param buffer - as buffer
function CAPABILITIES.default_completion(_, buffer)
    _default_completion(buffer)

    vim.api.nvim_buf_set_keymap(buffer,
        "i", "<C-x><C-p>",
        OMNIFUNC_CALLBACK.PRT_FUZZY_COMPLETION,
        { desc = "prt fuzzy completio manual trigger",  silent = true, noremap = true }
    )
end

-- @brief on_init
--
-- @param client - as client
-- @param _ - as buffer
function CAPABILITIES.on_init(client, _)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

-- @brief on_attach
--
-- @param _ - as client
-- @param buffer - as buffer
function CAPABILITIES.on_attach(_, buffer)
    _default_completion(buffer)
end

---

-- BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end

        _default_completion(buffer)

        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax off")
        end
    end
})
-- BufEnter
vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    callback = function(_)
        -- cmake: syntax case
        if vim.bo.filetype == "cmake" then
           vim.cmd("syntax on")
        end
    end
})
-- LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buffer = args.buf
        local buffer_name = vim.api.nvim_buf_get_name(buffer)

        if not vim.api.nvim_buf_is_valid(buffer) then return end
        if not client then return end
        if buffer_name == "" then return end

        _default_completion(buffer)
        CAPABILITIES.on_attach(client, buffer)
    end
})
-- InsertCharPre 
vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function(args)
        local buffer = args.buf

        if not vim.api.nvim_buf_is_valid(buffer) then return end
        if vim.api.nvim_buf_get_name(buffer) == "" then return end

        if vim.bo[buffer].omnifunc ~= "" and vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
            vim.defer_fn(function()
                -- validate state first, prevent close buffer
                if vim.api.nvim_buf_is_valid(buffer) and
                   vim.api.nvim_get_current_buf() == buffer and
                   vim.fn.mode() == "i" then
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        OMNIFUNC_CALLBACK.PRT_FUZZY_COMPLETION,
                        true, true, true
                    ), "n")
                end
            end, COMPLETION_DELAY)
        end
    end
})
-- TextChangedI
-- vim.api.nvim_create_autocmd("TextChangedI", {
--     callback = function(args)
--         local buffer = args.buf
--
--         if not vim.api.nvim_buf_is_valid(buffer) then return end
--         if vim.api.nvim_buf_get_name(buffer) == "" then return end
--
--         if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
--             vim.defer_fn(function()
--                 -- validate state first, prevent close buffer
--                 if vim.api.nvim_buf_is_valid(buffer) and
--                    vim.api.nvim_get_current_buf() == buffer and
--                    vim.fn.mode() == "i" then
--                     vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
--                         OMNIFUNC_CALLBACK.PRT_FUZZY_COMPLETION,
--                         true, true, true
--                     ), "n")
--                 end
--             end, COMPLETION_DELAY)
--         end
--     end
-- })
-- FileType
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        if not vim.api.nvim_buf_is_valid(buffer) then return end

        _default_completion(buffer)
    end
})
-- -- BufNewFile & BufRead
-- vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
--     -- force file .h to c ad not c++
--     pattern = "*.h",
--     callback = function()
--         if vim.bo.filetype == "" or vim.bo.filetype == "cpp" then
--             vim.bo.filetype = "c"
--         end
--     end
-- })
-- CompleteDone
vim.api.nvim_create_autocmd("CompleteDone", {
    pattern = "*",
    callback = _handle_complete_done
})

---

return CAPABILITIES

