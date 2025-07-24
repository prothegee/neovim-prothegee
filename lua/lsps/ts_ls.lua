local M = {}

function M.initialize()
    local _lsp = "ts_ls"
    local _cmd = { "typescript-language-server" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "js", "jsx",
        "ts", "d.ts", "tsx",
        "javascript", "javascriptreact", "javascript.jsx",
        "typescript", "typescriptreact", "typescript.tsx"
    }
    local _root_markers = {
        { "jsconfig.json", "tsconfig.json", "package.json" }
    }
    local _settings = {}

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_ts_ls.lsp", {}),
        callback = function(args)
            _cap.on_attach(_, args.buf)
        end,
    })

    if vim.lsp.config then
        vim.lsp.config(_lsp, {
            settings = _settings
        })

        vim.lsp.enable(_lsp)
    else
        _lspconfig.ts_ls.setup({
            capabilities = _cap.capabilities,
            on_init = _cap.on_init,
            cmd = _cmd,
            filetypes = _filetypes,
            root_markers = _root_markers,
            settings = _settings,
        })
    end
end

return M
