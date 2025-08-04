vim.pack.add({
    {
        src = "git@github.com:neovim/nvim-lspconfig.git",
        name = "lspconfig",
        version = "master"
    },

    {
        src = "git@github.com:lewis6991/gitsigns.nvim.git",
        name = "gitsigns",
        version = "main"
    },
})

---

-- auto prepend
--- vim pack path
local _path1 = vim.fn.stdpath"data" .. "/site/pack/core/opt"
for _, path in ipairs(vim.fn.glob(_path1 .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)

        local path_lua_dir = path .. "/lua"

        if vim.fn.isdirectory(path_lua_dir) then
            vim.opt.rtp:append(path_lua_dir)
        end
    end
end

-- manual prepend
--- nvim-prt
local _path2 = vim.fn.stdpath"config" .. "/lua/nvim-prt"
for _, path in ipairs(vim.fn.glob(_path2 .. "/*", true, true)) do
    if vim.fn.isdirectory(path) then
        vim.opt.rtp:append(path)
    end
end

---

require"plugins.gitsigns"
require"plugins.prt"
