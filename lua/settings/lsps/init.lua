local _cap = require"nvim-prt.cmpltn"

---

-- default lsp/s
local LSPS = {
    "lua_ls",
    "clangd", "neocmake",
    "rust_analyzer",
    "gopls",
    "ts_ls",
    "svelte",
    "gdscript", "gdshader_lsp",
    "pyright",
    "html", "cssls",
    "jsonls",
    "markdown_oxide",
    -- "sqls",
}

---

-- init default
for _, lsp in pairs(LSPS) do
    -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
    local opts = {}

    -- use this instead since will be extended
    local ocap = {
        on_init = _cap.on_init,
        on_attach = _cap.on_attach,
        capabilities = _cap.capabilities
    }

    if lsp == "lua_ls" then
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
        opts.settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                        vim.fn.stdpath"config" .. "/lua"
                    }
                },
                workspace = {
                    library = {
                        "lua",
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        vim.fn.expand "$VIMRUNTIME/lua",
                        vim.fn.stdpath"config" .. "/lua"
                    },
                    checkThirdParty = true
                },
                diagnostics = {
                    globals = { "vim" }
                }
            }
        }
    end

    -- check opts before extend ocap
    if next(opts) ~= nil then
        ocap = vim.tbl_deep_extend("force", ocap, opts)
    end

    if vim.lsp.config then vim.lsp.config(lsp, ocap) end
end

-- default
vim.lsp.config("*", {
    on_init = _cap.on_init,
    on_attach = _cap.on_attach,
    capabilities = _cap.capabilities
})

-- finally
vim.lsp.enable(LSPS)

-- autocmd/s
_cap.default_autocmd(LSPS)
