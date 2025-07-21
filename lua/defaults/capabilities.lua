local M = {}

---

M.capabilities = vim.lsp.protocol.make_client_capabilities()


M.capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}

M.capabilities = vim.tbl_deep_extend("force", M.capabilities, require("cmp_nvim_lsp").default_capabilities())

---

M.on_int = function(client, _)
    if client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

M.on_attach = function(_, buff)
    local function opts(desc)
        return { buffer = buff, desc = "LSP: " .. desc }
    end

    vim.keymap.set("n", "gtdec",
        vim.lsp.buf.declaration,
        opts "got to declaration"
    )
    vim.keymap.set("n", "gtdef",
        vim.lsp.buf.definition,
        opts "got to definition"
    )
    vim.keymap.set("n", "gttdef",
        vim.lsp.buf.type_definition,
        opts "got to type definition"
    )
end

---

return M
