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
require"nvim-prt.cmdc".setup({
    commands = {
        ["Test 1"] = function()
            print("DEBUG: Test 1")
        end,
        ["Test 2"] = function()
            print("DEBUG: Test 2")
        end,
        ["Test 3"] = function()
            print("DEBUG: Test 3")
        end,
    }
})
