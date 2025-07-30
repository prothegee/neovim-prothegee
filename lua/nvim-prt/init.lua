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
        print("qweqweqwe")
        return
    end

    if opts.default then
        require"nvim-prt.cmdc"
        require"nvim-prt.xplrr"
    end
end

---

return NVIM_PRT
