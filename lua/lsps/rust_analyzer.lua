local M = {}

function M.initialize()
    local _lsp = "rust_analyzer"
    local _cmd = { "/home/pr/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "rs", "rust","Cargo.toml"
    }
    local _root_markers = {
        { "Cargo.toml" }
    }
    local _settings = {
        ["rust_analyzer"] = {
            diagnostics = {
                enable = true
            }
        }
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_rust_analyzer.lsp", {}),
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
        _lspconfig.rust_analyzer.setup({
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
