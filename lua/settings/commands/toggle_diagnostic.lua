local _cmd = {
    toggle_diagnostic_text = "ToggleDiagnosticText",
    toggle_diagnostic_lines = "ToggleDiagnosticLines",
    toggle_diagnostic_text_and_lines = "ToggleDiagnosticTextAndLines",
}

-- diagnostic text
vim.api.nvim_create_user_command(_cmd.toggle_diagnostic_text, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_text = cfg.virtual_text ~= false

    vim.diagnostic.config({
        virtual_text = not virt_text
    })
end, {})

-- diagnostic lines
vim.api.nvim_create_user_command(_cmd.toggle_diagnostic_lines, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_lines = cfg.virtual_lines ~= false

    vim.diagnostic.config({
        virtual_lines = not virt_lines
    })
end, {})

-- diagnostic text and lines
vim.api.nvim_create_user_command(_cmd.toggle_diagnostic_text_and_lines, function()
    local cfg = vim.diagnostic.config() or {}
    local virt_txt = cfg.virtual_text ~= false
    local virt_line = virt_txt and true or false

    vim.diagnostic.config({
        virtual_text = not virt_txt,
        virtual_lines = not virt_line
    })
end, {})
