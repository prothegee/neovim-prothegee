local NVIM = {}

---

NVIM.os = {
    windows = vim.fn.has"win32" == 1 or vim.fn.has"win64" == 1
}

---

-- # initialize .nvim
function NVIM.initialize()
    local target = vim.fn.getcwd() .. "/.nvim"

    if vim.fn.isdirectory(target) == 0 then
        vim.fn.mkdir(target, "p")
    end
end

---

return NVIM
