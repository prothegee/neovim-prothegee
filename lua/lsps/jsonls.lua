
local M = {}

function M.initialize()
    local _lsp = "jsonls"
    local _cmd = { "vscode-json-language-server", "--stdio" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "json", "jsonc",
    }
    local _root_markers = {
        { "package.json" }
    }
    local _settings = {}
    local _init_options = {
        provideFormatter = true
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_json.lsp", {}),
        callback = function(args)
            _cap.on_attach(_, args.buf)
        end,
    })

    if vim.lsp.config then
        vim.lsp.config(_lsp, {
            settings = _settings,
            init_options = _init_options
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
            init_options = _init_options
        })
    end
end

return M
