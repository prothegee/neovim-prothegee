local M = {}

function M.initialize()
    local _lsp = "lua_ls"
    local _cmd = { "lua-language-server" }
    local _cap = require"defaults.completion"
    local _lspconfig = require"lspconfig"
    local _filetypes = { "lua" }
    local _root_markers = {
        { ".luarc.json", ".luarc.jsonc", "init.lua" }
    }
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
            cmd = _cmd,
            filetypes = _filetypes,
            root_markers = _root_markers,
            settings = _settings,
        })
    end
end

return M
