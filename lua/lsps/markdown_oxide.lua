local M = {}

function M.initialize()
    local _lsp = "markdown_oxide"
    local _cmd = { "markdown-oxide" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "markdown", "md"
    }
    local _root_markers = {
        { ".obsidian", ".moxide.toml" }
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_markdown_oxide.lsp", {}),
        callback = function(args)
            _cap.on_attach(_, args.buf)
        end,
    })

    if vim.lsp.config then
        vim.lsp.enable(_lsp)
    else
        _lspconfig.ts_ls.setup({
            capabilities = _cap.capabilities,
            on_init = _cap.on_init,
            cmd = _cmd,
            filetypes = _filetypes,
            root_markers = _root_markers,
        })
    end
end

return M
