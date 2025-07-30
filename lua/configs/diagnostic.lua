-- common
--- sign define/s
--- somehow doesn't works in 0.12
--- https://neovim.io/doc/user/diagnostic.html
vim.fn.sign_define("DiagnosticSignHint",  { text = "", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo",  { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignWarn",  { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
--- wtd
vim.api.nvim_set_hl(0, "DiagnosticSignHint",  { fg = "#7fbbb3" })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo",  { fg = "#83a598" })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn",  { fg = "#fabd2f" })
vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#fb4934" })
--- default sign diagnostic sign/s
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.ERROR] = "",
        }
    },
    underline = true,
    float = {
        style = "default",
        border = "rounded"
    },
    virtual_text = {
        prefix = "●"
    }
})

-- markdown
--- error:
--- - for some reason _ treated as error
vim.cmd("hi link markdownError Normal")
