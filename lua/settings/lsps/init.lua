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

local COMPLETION_DELAY = 300

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
}

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
                        "lua/?/init.lua"
                    }
                },
                workspace = {
                    library = {
                        "lua",
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        vim.fn.expand "$VIMRUNTIME/lua"
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
        ocap.settings = opts.settings
    end

    -- do lsp config, otherwise use lspconfig
    if vim.lsp.config then
        vim.lsp.config(lsp, ocap)
    else
        _lsp[lsp].setup(ocap)
    end
end

-- do something on lsp attach
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        _cap.on_attach(_, args.buf)
    end
})

-- do something on typing
vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function()
        if vim.fn.pumvisible() == 0 then
            vim.defer_fn(function()
                if vim.fn.pumvisible() == 0 then
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        "<C-x><C-o>", true, true, true
                    ), "n")
                end
            end, COMPLETION_DELAY)
        end
    end
})

-- finally
vim.lsp.enable(LSPS)
