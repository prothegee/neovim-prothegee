-- integrate terminal
--- horizontal
vim.keymap.set("n", "<leader>th", function()
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
        desc = "Terminal: Toggle Horizontal",
        noremap = true,
    }
)
--- vertical
vim.keymap.set(
    "n", "<leader>tv",
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
        desc = "Terminal: Toggle Vertical",
        noremap = true,
    }
)
--- exit: if terminal - POSTPONE
vim.keymap.set(
    {"n", "t"}, "<C-A-t-x>",
    function()
        -- TODO: close terminal or all terminals
     end,
    {
        desc = "Terminal: Close"
    }
)
vim.keymap.set(
    {"n", "t"}, "<C-A-t-a-x>",
    function()
        -- TODO: close terminal or all terminals

        print("TODO: close all terminals")
     end,
    {
        desc = "Terminal: Close"
    }
)
