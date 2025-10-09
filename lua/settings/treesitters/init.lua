local nvim_ts_c = require"nvim-treesitter.configs"

-- default treesitters
local TREESITTERS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "go",
    "javascript", "typescript",
    "svelte",
    "gdscript", "gdshader",
    "python",
    "html", "css", "scss",
    "json", "jsonc", "json5",
    "markdown",
    "sql",
}

---

-- not sure this will be recalled or what
for _, treesitter in pairs(TREESITTERS) do
    vim.treesitter.language.add(treesitter)
end

nvim_ts_c.setup{
    ensure_installed = TREESITTERS,
    auto_install = true,
    sync_install = false,
    hightlight = {
        enable = true
    }
}

---

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf
        local filetype = vim.bo[buffer].filetype

        for _, treesitter in pairs(TREESITTERS) do
            if treesitter == filetype then
                if vim.treesitter.language.add(treesitter) then
                    vim.treesitter.start(buffer, treesitter)
                    vim.bo[buffer].syntax = "ON"

                    local cmd = "TSBufEnable " .. treesitter
                    vim.cmd(cmd)
                end
                break
            end
        end
    end,
})
