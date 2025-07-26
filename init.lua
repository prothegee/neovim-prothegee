vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local _plugin_path = vim.fn.stdpath "config" .. "/vendor"

local _matchs, _hidden, _specchar = true, false, false

local _vendors = vim.split(vim.fn.glob(_plugin_path .. "/*", _matchs, _hidden, _specchar), "\n")

for _, vendor in ipairs(_vendors) do
    if vim.fn.isdirectory(vendor) == 1 then
        vim.opt.rtp:prepend(vendor)

        local vendor_lua_dir = vendor .. "/lua"

        if vim.fn.isdirectory(vendor_lua_dir) then
            vim.opt.rtp:prepend(vendor_lua_dir)
        end
    end
end

require"initialize"
