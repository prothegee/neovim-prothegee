-- integrate terminal
--- horizontal
vim.keymap.set(
    "n", "<A-h>",
    function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buffer = vim.api.nvim_win_get_buf(win)
            if vim.bo[buffer].buftype == "terminal" then
                vim.api.nvim_win_close(win, true)
                return
            end
        end

        vim.cmd("botright 12split | terminal")
    end,
    {
        desc = "Terminal: Horizontal",
        noremap = true,
        silent = true
    }
)
--- vertical
vim.keymap.set(
    "n", "<A-v>",
    function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buffer = vim.api.nvim_win_get_buf(win)
            if vim.bo[buffer].buftype == "terminal" then
                vim.api.nvim_win_close(win, true)
                return
            end
        end

        vim.cmd("botright 45vsplit | terminal")
    end,
    {
        desc = "Terminal: Vertical",
        noremap = true,
        silent = true
    }
)
