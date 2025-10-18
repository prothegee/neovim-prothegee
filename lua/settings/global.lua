-- get active lsp
_G.get_active_lsp = function()
    local clients = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(clients, client.name)
    end
    if #clients > 0 then
        return "" .. table.concat(clients, ", ") .. " "
    end
    return "n/a "
end

-- get active mode
_G.get_active_current_mode = function()
    local mode_map = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        [""] = "V-BLOCK",  -- Ctrl-V
        c = "COMMAND",
        s = "SELECT",
        S = "S-LINE",
        [""] = "S-BLOCK",
        t = "TERMINAL",
        R = "REPLACE",
        ["!"] = "SHELL",
        r = "PROMPT",
    }
    local mode_code = vim.api.nvim_get_mode().mode
    return mode_map[mode_code] or string.upper(mode_code)
end

-- get dianostic hint
_G.get_diagnostic_hint = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.HINT then
            total = total + 1
        end
    end

    return total
end

-- get dianostic info
_G.get_diagnostic_info = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.INFO then
            total = total + 1
        end
    end

    return total
end

-- get dianostic warn
_G.get_diagnostic_warn = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.WARN then
            total = total + 1
        end
    end

    return total
end

-- get dianostic error
_G.get_diagnostic_error = function ()
    local diags = vim.diagnostic.get(0)

    local total = 0

    for _, diag in ipairs(diags) do
        if diag.severity == vim.diagnostic.severity.ERROR then
            total = total + 1
        end
    end

    return total
end

