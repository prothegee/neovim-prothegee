local NVIM_PRT = {}

---

NVIM_PRT.options = {
    default = false,

    cmdc = {
        init = false
    },

    xplrr = {
        init = false
    }
}

---

function NVIM_PRT.setup(opts)
    opts = vim.tbl_extend("force", NVIM_PRT.options, opts or {})

    if next(opts) == nil then
        vim.schedule(function()
            vim.notify("INFO: NVIM_PRT opts from setup is nil", vim.log.levels.INFO)
        end)
        return
    end

    if opts.default then
        require"nvim-prt.cmdctr"
        require"nvim-prt.xplrr"
    end
end

---

return NVIM_PRT
