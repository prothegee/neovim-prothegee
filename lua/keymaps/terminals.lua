-- integrate terminal
--- horizontal
vim.keymap.set("n", "<leader>th", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end

    vim.cmd("botright 12split | terminal")
end, {
    desc = "Terminal: Toggle Horizontal",
    noremap = true,
})
--- vertical
vim.keymap.set("n", "<leader>tv", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end

    vim.cmd("botright 45vsplit | terminal")
end, {
    desc = "Terminal: Toggle Vertical",
    noremap = true,
})
