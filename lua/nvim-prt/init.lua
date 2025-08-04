local NVIM_PRT = {}

---

-- nvim-prt options
NVIM_PRT.options = {
    default = false,
}

-- actual nvim-prt dir
NVIM_PRT.dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

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
        require"nvim-prt.cmdc"
        require"nvim-prt.xplrr"
    end
end

---

return NVIM_PRT
