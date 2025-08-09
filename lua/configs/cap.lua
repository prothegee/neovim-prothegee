local CAP = {}

local COMPLETION_DELAY = 899

---

local _buf_default_completion = function(buffer)
    -- https://neovim.io/doc/user/options.html#'completeopt'
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
end

local _buf_helper_completion = function(buffer, ...)
    vim.api.nvim_buf_set_keymap(buffer, ...)
end

local _completion_trigger = function(client, buffer)
    vim.opt.shortmess:append("c")
    vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"

    _buf_default_completion(buffer)

    -- mode: insert
    -- trigger by using ctrl+space
    _buf_helper_completion(
        buffer,
        "i", "<C-space>",
        "<C-x><C-o>",
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
    contextSupport = true,
}
-- base completion completionItem
CAP.capabilities.textDocument.completion.completionItem = {
    tagSupport = { valueSet = { 1 } },
    snippetSupport = true,
    resolveSupport = {
        properties = { "detail", "documentation", "additionalTextEdits" }
    },
    preselectSupport = true,
    deprecatedSupport = true,
    labelDetailsSupport = true,
    documentationFormat = { "markdown", "plaintext" },
    insertReplaceSupport = true,
    insertTextModeSupport = {
        valueSet = { 1, 2 }
    },
    commitCharactersSupport = true,
}

---

-- on init
function CAP.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
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

function CAP.default_autocmd()
    --[[
    NOTE:
    * problem:
        - some buffer where it not supported lsp, it throw error of omnifunc
    --]]
    -- BufEnter
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function(args)
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

            if vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    if vim.fn.pumvisible() == 0 then
                        vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                            "<C-x><C-o>", true, true, true
                        ), "n")
                    end
                end, COMPLETION_DELAY)
            end
        end
    })
    -- TextChangedI TextChangedP
    vim.api.nvim_create_autocmd({"TextChangedI", "TextChangedP"}, {
        callback = function(args)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.fn.pumvisible() == 0 then
                vim.fn.complete(
                    vim.fn.col(".") - 1, vim.fn.getline("."):match("%w+$")
                    and
                    vim.fn.getcompletion(vim.fn.getline("."):match("%w+$"), "buffer")
                    or
                    {}
                )
            end
        end
    })
end

---

return CAP
