local NVIM_TOOLS = {}

local _config = require"nvim-tools.config"

---

function NVIM_TOOLS.setup(opts)
    opts = vim.tbl_deep_extend("force", _config.options, opts or {})

    _config.initialize(opts)
end

---

return NVIM_TOOLS
