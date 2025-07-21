local M = {}

local _filetypes = { "lua" }

local _settings = {
    Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = {
            globals = { "vim" }
        },
        workspace = {
            library = {
                vim.fn.expand "$VIMRUNTIME/lua",
                "${3rd}/luv/library",
            }
        }
    }
}

---

function M.initialize()
    local _lsp = "lua_ls"
    local _cap = require "defaults.capabilities"
    local _lspconfig = require "lspconfig"

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("_attach_lua.lsp", {}),
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
            settings = _settings,
            filetypes = _filetypes,
        })
    end
end

return M
