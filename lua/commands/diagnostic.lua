vim.api.nvim_create_user_command(
    "NvimDiagnos",
    function()
        require"utils.diagnostic".diagnostic_toggle()
    end,
    {}
)

vim.api.nvim_create_user_command(
    "NvimDiagnosAll",
    function()
        require"utils.diagnostic".diagnostic_toggle_all()
    end,
    {}
)
