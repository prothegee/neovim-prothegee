local M = {}

function M.initialize()
    local _lsp = "neocmake"
    local _cmd = { "neocmakelsp" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = {
        "CMakeLists.txt", "cmake"
    }
    local _root_markers = {
        { "CMakeLists.txt", "CMakePresets.json", "compile_commands.json" }
    }
    local _settings = {}

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_neocmake.lsp", {}),
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
        _lspconfig.neocmake.setup({
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
