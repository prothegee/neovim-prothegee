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

-- specific: lua
require"lsps.lua_ls".initialize()
-- specific: clangd
-- specific: neocmake
