vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local _plugin_path = vim.fn.stdpath "config" .. "/vendor"

for _, vendor in pairs(vim.fn.glob(_plugin_path .. "/*", 0, 1, 2)) do
    if vim.fn.isdirectory(vendor) == 1 then
        vim.opt.rtp:prepend(vendor)

        local vendor_lua_dir = vendor .. "/lua"

        if vim.fn.isdirectory(vendor_lua_dir) then
            vim.opt.rtp:prepend(vendor_lua_dir)
        end
    end
end

require"initialize"
