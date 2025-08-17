-- default treesitters
local TREESITTERS = {
    "lua",
    "c", "cpp", "cmake",
    "rust",
    "javascript", "typescript",
    "svelte",
    "gdsciprt", "gdshader",
    "python",
    "htmls", "css", "scss",
    "json",
    "markdown",
}

---

-- not sure this will be recalled or what
for _, treesitter in pairs(TREESITTERS) do
    -- TODO
    vim.treesitter.language.add(treesitter)
end

---

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buffer = args.buf

        for _, treesitter in pairs(TREESITTERS) do
            if vim.treesitter.language.add(treesitter) then
                vim.treesitter.start(buffer, treesitter)
                vim.bo[buffer].syntax = "ON"
                break
            end
        end
    end,
})
