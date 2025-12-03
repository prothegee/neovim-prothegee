local function _init_install_plugin()
    vim.pack.add({
        {
            src = "git@github.com:neovim/nvim-lspconfig.git",
            -- name = "lspconfig",
            -- version = "master"
        },
        {
            src = "git@github.com:nvim-treesitter/nvim-treesitter.git",
            -- name = "nvim-treesitter",
            -- version = "master"
        },

        {
            src = "git@github.com:shellRaining/hlchunk.nvim.git",
            -- name = "hlchunk",
            -- version = "main"
        },
        {
            src = "git@github.com:lewis6991/gitsigns.nvim.git",
            -- name = "gitsigns",
            -- version = "main"
        },

        {
            src = "git@github.com:olimorris/onedarkpro.nvim.git",
            -- name = "onedarkpro",
            -- version = "main"
        },

        {
            src = "git@github.com:MeanderingProgrammer/render-markdown.nvim.git",
            -- name = "render-markdown",
            -- version = "main"
        },

        {
            src = "git@github.com:hrsh7th/cmp-nvim-lsp.git"
        },
        {
            src = "git@github.com:hrsh7th/cmp-buffer.git"
        },
        {
            src = "git@github.com:hrsh7th/cmp-path.git"
        },
        {
            src = "git@github.com:hrsh7th/cmp-cmdline.git"
        },
        {
            src = "git@github.com:hrsh7th/nvim-cmp.git"
        },
        {
            src = "git@github.com:hrsh7th/cmp-vsnip.git"
        },
        {
            src = "git@github.com:hrsh7th/vim-vsnip.git"
        },
        {
            src = "git@github.com:hrsh7th/vim-vsnip-integ.git"
        },

        {
            src = "git@github.com:chomosuke/typst-preview.nvim.git"
        }
    })
end

local function _append_vim_pack_path()
    local paths = vim.fn.stdpath"data" .. "/site/pack/core/opt"
    for _, path in ipairs(vim.fn.glob(paths .. "/*", true, true)) do
        if vim.fn.isdirectory(path) then
            vim.opt.rtp:append(path)

            local path_lua_dir = path .. "/lua"

            if vim.fn.isdirectory(path_lua_dir) then
                vim.opt.rtp:append(path_lua_dir)
            end
        end
    end
end

local function _append_nvim_prt_path()
    local paths = vim.fn.stdpath"config" .. "/lua/nvim-prt"
    for _, path in ipairs(vim.fn.glob(paths .. "/*", true, true)) do
        if vim.fn.isdirectory(path) then
            vim.opt.rtp:append(path)
        end
    end
end

---

-- vim.schedule(function()
    _init_install_plugin()
    _append_vim_pack_path()
    _append_nvim_prt_path()

    -- extend
    require"plugins.gitsigns"
    require"plugins.hlchunk"
    require"plugins.onedarkpro"
    require"plugins.render-markdown"
    require"plugins.cmp"
    require"plugins.typst-preview"
    require"plugins.nvim-prt"
-- end)

