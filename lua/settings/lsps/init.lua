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

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    local ft = ev.match
    local server = LSPS[ft]
    if not server then return end

    -- Avoid duplicate servers
    for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = ev.buf })) do
      if client.name == server then return end
    end

    local config = vim.tbl_deep_extend("force",
      vim.lsp.config.defaults or {},
      server_settings[server] or {}
    )

    -- Use lspconfig's .server field to get cmd, root_dir, etc.
    local server_def = _lsp[server]
    if not server_def then return end

    local opts = server_def.server
    if opts.root_dir then
      config.root_dir = opts.root_dir(vim.api.nvim_buf_get_name(ev.buf))
    end
    if opts.cmd then
      config.cmd = opts.cmd
    end
    if opts.filetypes then
      config.filetypes = opts.filetypes
    end
    -- Add other fields as needed (init_options, etc.)

    vim.lsp.start(config)
  end
})

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
