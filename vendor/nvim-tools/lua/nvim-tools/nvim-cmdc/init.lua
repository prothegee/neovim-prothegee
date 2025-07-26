local NVIM_CMDC = {}

local _telescope = {
    actions = require"telescope.actions",
    actions_state = require"telescope.actions.state",
    pickers = require"telescope.pickers",
    finders = require"telescope.finders",
    config = require"telscope.config"
}

---

NVIM_CMDC.default = {
    mode = {
        all = { "i", "n" },
        insert = "i",
        normal = "n"
    },
    lhs = "<C-A-p>",
    command = "NvimCommandCenter",
    description = "Nvim Command Center"
}

NVIM_CMDC.prompt_title = "Nvim Command Center"

NVIM_CMDC.cmd_list = {
    ["Nvim CMDC: Hello"] = function()
        print("Hello, this is Nvim CMDC")
    end,
}

---

function NVIM_CMDC.show_ui()
    -- sorting command list alphabetically
    local command_keys = vim.tbl_keys(NVIM_CMDC.cmd_list)
    table.sort(command_keys, function(a,b)
        return a:lower() < b:lower()
    end)

    -- _telescope.pickers.new({})
end

---

return NVIM_CMDC
