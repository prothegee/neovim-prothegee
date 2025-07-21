local _lua_plugin_vendors = vim.fn.stdpath "config" .. "/lua/plugins"

for _, vendor in pairs(vim.fn.glob(_lua_plugin_vendors .. "/**/*", 0, 1, 2)) do
    if vim.fn.isdirectory(vendor) == 1 then
	vim.opt.rtp:prepend(vendor)

	local vendor_lua_dir = vendor .. "/lua"

	if vim.fn.isdirectory(vendor_lua_dir) then
	    vim.opt.rtp:prepend(vendor_lua_dir)
	end
    end
end

require "configs"
require "lsps"
require "utils"
require "keymaps"
