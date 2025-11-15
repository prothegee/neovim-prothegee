local _hlchunk = require"hlchunk"

local _DELAY = 60

_hlchunk.setup({
    chunk = {
        enable = true,
        delay = _DELAY
    },
    indent = {
        enable = true,
        delay = _DELAY
    },
    line_num = {
        enable = true,
        delay = _DELAY
    },
    blank = {
        enable = false
    },
    context = {
        enable = false
    }
})

