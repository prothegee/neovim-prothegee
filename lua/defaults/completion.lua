
local M = {}

local DELAY_COMPLETION = 0

local helper_lsp_buf = function()
    vim.keymap.set("n", "<leader>gtdec",
        vim.lsp.buf.declaration,
        {
            desc = "LSP: go to declaration"
        }
    )
    vim.keymap.set("n", "<leader>gtdef",
        vim.lsp.buf.definition,
        {
            desc = "LSP: go to definition"
        }
    )
    vim.keymap.set("n", "<leader>gttdef",
        vim.lsp.buf.type_definition,
        {
            desc = "LSP: go to type definition"
        }
    )
end

local completion_trigger_manually = function(client, bufnr)
    vim.opt.completeopt = { "menu", "menuone", "noinsert" }
    vim.opt.shortmess:append("c")
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    buf_set_keymap("i", "<C-Space>", "<C-x><C-o>", {noremap = true, silent = true})

    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = function()
            local char = vim.v.char

            if char == "." or char == ":" then
                vim.schedule(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true), "n")
                end)
            end
        end
    })

end

local completion_trigger_auto = function(client, bufnr)
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    local function trigger_completion()
        if vim.fn.pumvisible() == 0 then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true), "n")
        end
    end

    -- default keymap for some user
    vim.keymap.set("i", "<C-n>", function()
        return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-o>"
    end, { expr = true, buffer = bufnr, desc = "LSP: trigger completion or select next item" })
    vim.keymap.set("i", "<C-p>", function()
        return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-x><C-o>"
    end, { expr = true, buffer = bufnr, desc = "LSP: trigger completion or select previous item" })

    vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = bufnr,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before = line:sub(1, col)

            if before:match("[%w_][%.%:]$") then
                vim.defer_fn(trigger_completion, DELAY_COMPLETION)
            end
        end
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        buffer = bufnr,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before = line:sub(1, col)

            if before:match("[%w_][%.%:]$") then
                vim.defer_fn(trigger_completion, DELAY_COMPLETION)
            end
        end
    })
end

---

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion = {
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
    },
}

---

M.on_init = function(client, bufnr)
    if client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

M.on_attach = function(client, bufnr)
    helper_lsp_buf()
    completion_trigger_manually(client, bufnr)
    completion_trigger_auto(client, bufnr)
end

return M
