local CAPABILITIES = {}

---

-- local TRIGGER_KIND = 3
local COMPLETION_DELAY = 60

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
    vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- custom snippet
    -- part of global.lua
    vim.api.nvim_buf_set_keymap(buffer,
        "i", "<C-x><C-p>",
        "<cmd>call v:lua.prt_fuzzy_snippet(0, '')<CR>", {
            desc = "prt custom snippet trigger",
            silent = true,
            noremap = true
        }
    )
end

---

-- @brief default completion
--
-- @param _ - as client
-- @param buffer - as buffer
function CAPABILITIES.default_completion(_, buffer)
    _default_completion(buffer)
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
                        "<C-x><C-o>",
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
--                         "<C-x><C-o>",
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

---

return CAPABILITIES

