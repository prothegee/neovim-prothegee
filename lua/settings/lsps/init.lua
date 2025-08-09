local _cap = require"configs.cap"
local _lsp = require"lspconfig"

---

-- for available lsp use default
if vim.lsp.config then
    vim.lsp.config("*", {
        on_init = _cap.on_attach,
        capabilities = _cap.capabilities
    })
end

---

-- default lsp/s
local LSPS = {
    "lua_ls",
    "clangd", "neocmake",
    "rust_analyzer",
    "ts_ls",
    "svelte",
    "html", "cssls",
    "jsonls",
    "markdown_oxide",
    "gdscript", "gdshader_lsp"
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
        -- ocap.settings = opts.settings -- v0
        ocap = vim.tbl_deep_extend("force", ocap, opts)
    end

    -- do lsp config, otherwise use lspconfig
    if vim.lsp.config then
        vim.lsp.config(lsp, ocap)
    else
        _lsp[lsp].setup(ocap)
    end
end

-- autocmd/s
_cap.default_autocmd()

-- finally
vim.lsp.enable(LSPS)
