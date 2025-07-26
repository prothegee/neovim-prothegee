local DIAGNOSTIC = {}

---

DIAGNOSTIC.opts = {
    virtual_text = false,
    virtual_lines = false,
}

---

function DIAGNOSTIC.diagnostic_toggle()
    local cfg = vim.diagnostic.config() or {}
    local virt_txt = cfg.virtual_text ~= false

    vim.diagnostic.config({
        virtual_text = not virt_txt
    })
end

function DIAGNOSTIC.diagnostic_toggle_all()
    local cfg = vim.diagnostic.config() or {}
    local virt_txt = cfg.virtual_text ~= false
    local virt_line = virt_txt and true or false

    vim.diagnostic.config({
        virtual_text = not virt_txt,
        virtual_lines = not virt_line
    })
end

---

-- diagnostic
--- config
vim.diagnostic.config(DIAGNOSTIC.opts)

--- message 
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })


-- markdown
--- error as normal
vim.cmd("hi link markdownError Normal")

---

return DIAGNOSTIC
