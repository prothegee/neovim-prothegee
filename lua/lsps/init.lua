local _cap = require "defaults.capabilities"

if vim.lsp.config then
    vim.lsp.config("*", {
        capabilities = _cap.capabilities,
        on_init = _cap.on_init
    })
end

-- specific lua
require"lsps.lua".initialize()
