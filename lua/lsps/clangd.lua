local M = {}

function M.initialize()
    local _lsp = "clangd"
    local _cmd = { "clangd" }
    local _cap = require "defaults.capabilities"
    local _lspconfig = require "lspconfig"
    local _filetypes = {
        "c", "h",
        "cc", "hh",
        "cpp", "hpp",
        "objc", "objcpp", "cuda"
    }
    local _root_markers = {
        { "compile_commands.json", ".clang-format", "CMakeLists.txt" }
    }
    local _settings = {}

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_clangd.lsp", {})
,
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
        _lspconfig.lua_ls.setup({
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
