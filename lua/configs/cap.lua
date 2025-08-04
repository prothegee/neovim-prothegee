local CAP = {}

---

local _buf_default_completion = function(bufnum)
    -- https://neovim.io/doc/user/options.html#'completeopt'
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
end

local _buf_helper_completion = function(bufnum, ...)
    vim.api.nvim_buf_set_keymap(bufnum, ...)
end

local _completion_trigger = function(client, bufnum)
    vim.opt.shortmess:append("c")
    vim.bo[bufnum].omnifunc = "v:lua.vim.lsp.omnifunc"

    _buf_default_completion(bufnum)

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
function CAP.on_init(client, bufnum)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

-- on attach
function CAP.on_attach(client, bufnum)
    _completion_trigger(client, bufnum)
end

-- default completion
function CAP.default_completion(bufnum)
    _buf_default_completion(bufnum)
end

---

return CAP
