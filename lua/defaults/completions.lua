local _cmp = require "cmp"
local _luasnip = require "luasnip"

local M = {}

M.options = {
    completion = {
        completeopt = "menu,menuone"
    },
    snippet = {
        expand = function(args)
            _luasnip.lsp_expand(args.body)
        end
    },
    window = {
        completion = _cmp.config.window.bordered(),
        documentation = _cmp.config.window.bordered(),
    },
    performance = {
        debounce = 90
    },
    mapping = {
        ["<C-p>"] = _cmp.mapping.select_prev_item(),
        ["<C-n>"] = _cmp.mapping.select_next_item(),
        ["<C-d>"] = _cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = _cmp.mapping.scroll_docs(4),
        ["<C-e>"] = _cmp.mapping.close(),
        ["<C-Space>"] = _cmp.mapping.complete(),
        ["<CR>"] = _cmp.mapping.confirm {
              behavior = _cmp.ConfirmBehavior.Insert,
              select = true,
        },

        ["<Tab>"] = _cmp.mapping(function(fallback)
            if _cmp.visible() then
                _cmp.select_next_item()
            elseif _luasnip.expand_or_jumpable() then
                _luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = _cmp.mapping(function(fallback)
            if _cmp.visible() then
                _cmp.select_prev_item()
            elseif _luasnip.jumpable(-1) then
                _luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "async_path" },
    },
}

return M
