local M = {}

function M.initialize()
    local _lsp = "clangd"
    local _cmd = { "clangd" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "c", "h",
        "cc", "hh",
        "cpp", "hpp",
        "objc", "objcpp", "cuda"
    }
    local _root_markers = {
        { "compile_commands.json", ".clang-format", "CMakeLists.txt" }
    }

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_clangd.lsp", {}),
        callback = function(args)
            _cap.on_attach(_, args.buf)
        end,
    })

    if vim.lsp.config then
        vim.lsp.enable(_lsp)
    else
        _lspconfig.clangd.setup({
            capabilities = _cap.capabilities,
            on_init = _cap.on_init,
            cmd = _cmd,
            filetypes = _filetypes,
            root_markers = _root_markers,
        })
    end
end

return M
