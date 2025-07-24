-- default lsps
local _default_lsps = {
    "clangd", "neocmake",
    "rust_analyzer",
    "ts_ls",
    "svelte",
    "html", "cssls",
    "jsonls",
    "markdown_oxide",
}
vim.lsp.enable(_default_lsps)

require"lsps.lua_ls".initialize()
require"lsps.clangd".initialize()
require"lsps.neocmake".initialize()
require"lsps.rust_analyzer".initialize()
require"lsps.ts_ls".initialize()
require"lsps.svelte".initialize()
require"lsps.markdown_oxide".initialize()
require"lsps.html".initialize()
require"lsps.cssls".initialize()
require"lsps.jsonls".initialize()
