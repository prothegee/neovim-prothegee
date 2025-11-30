local _cmp = require"cmp"

_cmp.setup({
    enabled = function()
        local buftype = vim.bo.filetype
        if buftype == "prompt" then
            return false
        end
        local is_floating = vim.api.nvim_win_get_config(0).relative ~= ""
        if is_floating then
        return false
        end
        return true
    end,
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    window = {
        completion = _cmp.config.window.bordered(),
        documentation = _cmp.config.window.bordered(),
    },
    mapping = _cmp.mapping.preset.insert({
        -- ["<C-b>"] = _cmp.mapping.scroll_docs(-4),
        -- ["<C-f>"] = _cmp.mapping.scroll_docs(4),
        -- ["<C-Space>"] = _cmp.mapping.complete(),
        ["<C-e>"] = _cmp.mapping.abort(),
        ["<CR>"] = _cmp.mapping.confirm({ select = false }),
    }),
    sources = _cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "vsnip" },
    }, {
        { name = "buffer" },
        { name = "path" },
    })
});

-- remove hightlight after completion
vim.g.vsnip_highlight_match = 0

-- replace snippet directory
vim.g.vsnip_snippet_dir = "~/.config/nvim/.vsnip"

