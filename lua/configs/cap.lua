local CAP = {}

--[[

-- completion was triggered by typing an identifier (24x7 code
-- complete), manual invocation (e.g ctrl+space) or via api.
1:invoked

-- completion was triggered by a trigger character specified by
-- the `triggercharacters` properties of the `completionregistrationoptions`.
2:triggercharacter

-- completion was re-triggered as the current completion list is incomplete.
3:triggerforincompletecompletions
--]]
local TRIGGER_KIND = 3

local COMPLETION_DELAY = 150 -- in milliseconds

---

-- custom omnifunc for fuzzy completion
_G._fuzzy_completion_omnifunc = function(findstart, base)
    if findstart == 1 then
        local line = vim.fn.getline(".")
        local col = vim.fn.col(".")
        return (line:sub(1, col):find("[%w_]*$") or col) - 1
    else
        local buf = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1] - 1, cursor[2]

        vim.lsp.buf_request(buf, "textDocument/completion", {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = { line = row, character = col },
            context = { triggerKind = TRIGGER_KIND },
        }, function(err, result, _)
            if err or not result then return end

            -- handle both completion list and plain array responses
            local items = result.items or result
            if not items then return end

            local matches = {}
            local base_lower = base:lower()

            for _, item in ipairs(items) do
                local label = item.textEdit and item.textEdit.newText or item.label
                if label and label:lower():find(base_lower, 1, true) then
                    -- completion item kind information
                    local kind_char = ""
                    local kind_text = ""

                    if item.kind then
                        kind_text = vim.lsp.protocol.CompletionItemKind[item.kind] or ""
                        kind_char = kind_text:sub(1, 1):lower()
                    end

                    table.insert(matches, {
                        word = label,
                        abbr = label:gsub("%b()", ""),
                        kind = kind_char,  -- single character for kind column
                        menu = kind_text,  -- full kind text for right side
                        info = item.documentation and (
                            type(item.documentation) == "string" and item.documentation or
                            (item.documentation.value or "")
                        ) or "",
                    })
                end
            end

            vim.fn.complete(col - #base + 1, matches)
        end)

        return {}
    end
end

---

local _buf_default_completion = function(buffer)
    -- https://neovim.io/doc/user/options.html#'completeopt'
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect", "popup" }
end

local _completion_trigger = function(client, buffer)
    vim.opt.shortmess:append("c")
    vim.bo[buffer].omnifunc = "v:lua._fuzzy_completion_omnifunc"

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

-- this default capabilities
CAP.capabilities = vim.lsp.protocol.make_client_capabilities()
-- base completion
CAP.capabilities.textDocument.completion = {
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
function CAP.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semantictokensprovider = nil
    end
end

-- on attach
function CAP.on_attach(client, buffer)
    _completion_trigger(client, buffer)
end

---

-- default completion
function CAP.default_completion(buffer)
    _buf_default_completion(buffer)
end

-- # default auto command
-- ---
-- # note
-- * will reject if current server not supported from supported_lsps param
function CAP.default_autocmd(supported_lsps)
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
            local buffer_name = vim.fn.expand("%")

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then
                -- this section can prevent error if buffer is not recoqnized
                CAP.default_completion(buffer)
            end
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

            CAP.on_attach(client, buffer)
        end
    })
    -- InsertCharPre
    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = function(args)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        "<C-x><C-o>", true, true, true
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
                        "<cmd>call v:lua._fuzzy_completion_omnifunc(0, '')<CR>", true, true, true
                        -- "<C-x><C-o>", true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
end

---

return CAP
