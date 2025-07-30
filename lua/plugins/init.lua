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

require"gitsigns".setup()

require"nvim-prt".setup({
    default = true
})
