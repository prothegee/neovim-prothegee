local _prt = {
    slr = require"nvim-prt.slr",
    cmdc = require"nvim-prt.cmdc",
    xplrr = require"nvim-prt.xplrr"
}

---

-- cmdc
_prt.cmdc.setup({
    commands = {
        -- ??
    }
})

---

_prt.slr.setup()
_prt.xplrr.setup()

