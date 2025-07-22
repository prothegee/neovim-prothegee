local _cap = require "defaults.capabilities"
local _lang = require "defaults.languages"

if vim.lsp.config then
    vim.lsp.config("*", {
        capabilities = _cap.capabilities,
        on_init = _cap.on_init
    })
end

-- default lsp
vim.lsp.enable(_lang.servers.protocol)

--[[
for complete list from neovim lspconfig go here
https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
--]]

-- specific: lua
require"lsps.lua_ls".initialize()
-- specific: clangd
require"lsps.clangd".initialize()
-- specific: neocmake
require"lsps.neocmakelsp".initialize()
-- specific: rust_analyzer
-- specific: javascript & typescript
-- specific: svelte
