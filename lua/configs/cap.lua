local CAP = {}

---

local _buf_helper_completion = function(bufnum, ...)
    vim.api.nvim_buf_set_keymap(bufnum, ...)
end

local _completion_trigger = function(client, bufnum)
    vim.opt.shortmess:append("c")
    vim.bo[bufnum].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- https://neovim.io/doc/user/options.html#'completeopt'
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

    -- mode: insert
    -- trigger by using ctrl+space
    _buf_helper_completion(
        bufnum,
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
-- base
CAP.capabilities.textDocument.completion = {
    dynamicRegistration = true,
    contextSupport = true,
    completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport = true,
        preselectSupport = true,
        insertReplaceSupport = true,
        labelDetailsSupport = true,
        commitCharactersSupport = true,
        tagSupport = { valueSet = { 1 } },
        resolveSupport = {
            properties = {
                "detail",
                "documentation",
                "additionalTextEdits"
            }
        },
        insertTextModeSupport =  {
            valueSet = { 1, 2 }
        },
        contextSupport = true
    }
}

---

-- on init
function CAP.on_init(client, bufn)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

-- on attach
function CAP.on_attach(client, bufnum)
    _completion_trigger(client, bufnum)
end

---

return CAP
