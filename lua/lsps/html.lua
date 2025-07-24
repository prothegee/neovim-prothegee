local M = {}

function M.initialize()
    local _lsp = "html"
    local _cmd = { "vscode-html-language-server", "--stdio" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "html", "templ",
    }
    local _root_markers = {
        { "package.json" }
    }
    local _settings = {}
    local _init_options = {
        configurationSection = {
            "html", "css", "javascript"
        },
        embeddedLanguages = {
            css = true,
            javascript = true
        },
        provideFormatter = true
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_html.lsp", {}),
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
