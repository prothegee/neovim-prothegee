-- NetrwDir
vim.api.nvim_create_user_command("NetrwDir", function()
    -- check if netrw is open and close it if found
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "netrw" then
            vim.cmd("bdelete " .. buf)
            return
        end
    end

    -- netrw configs
    vim.cmd("vertical leftabove 30Lex")
    vim.cmd("setlocal nowrap nonumber norelativenumber")

    -- toggle banner
    -- vim.cmd("silent! normal I")

    -- iter 3 times for mode number 4
    -- 0:thin 1:long 2:wide 3:tree
    local MODE = 3
    for i = 1, MODE do
        vim.cmd("silent! normal i")
    end
end, {})
