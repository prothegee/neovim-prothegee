local M = {}

function M.initialize()
    local _lsp = "svelte"
    local _cmd = { "svelteserver", "--stdio" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "svelte"
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_svelte.lsp", {}),
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
        })
    end
end

return M
