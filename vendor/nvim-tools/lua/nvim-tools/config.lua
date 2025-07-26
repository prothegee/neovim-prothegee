local CONFIG = {}

---

CONFIG.NAME = "nvim-tools"

CONFIG.path = {
    data = vim.fn.stdpath("data"),
    config = vim.fn.stdpath("config"),

    current = {
        dir = vim.fn.getcwd(),
        dot_nvim = vim.fn.getcwd() .. "/.nvim",
    },

    nvim_tools = {
        dir = vim.fn.stdpath("data") .. "/nvim-tools",
        dir_template = require"nvim-tools.utils".get_nvim_tools_template_dir(),
    }
}

CONFIG.file_template = {
    dot_clang_format = require"nvim-tools.utils".get_nvim_tools_template_dir() .. ".clang-format",
    dot_rustfmt_dot_toml = require"nvim-tools.utils".get_nvim_tools_template_dir() .. ".rustfmt.toml",
    cmake_presets_dot_json = require"nvim-tools.utils".get_nvim_tools_template_dir() .. "CMakePresets.json",
}

CONFIG.options = {
    default = true,

    nvim_cmake = {},

    nvim_sessman = {},

    nvim_cmdc = {}
}

---

local function init_path()
    if vim.fn.isdirectory(CONFIG.path.nvim_tools.dir) == 0 then
        vim.fn.mkdir(CONFIG.path.nvim_tools.dir, "p")
    end

    if vim.fn.isdirectory(CONFIG.path.nvim_tools.dir_template) == 0 then
        vim.fn.mkdir(CONFIG.path.nvim_tools.dir_template)
    end
end
---

function CONFIG.has_nvim_dap()
    if require"dap" then
        return true
    end
    return false
end

function CONFIG.has_nvim_dap_ui()
    if require"dapui" then
        return true
    end
    return false
end

function CONFIG.has_nvim_tree()
    if require"nvim-tree" then
        return true
    end
    return false
end

function CONFIG.has_nvim_telescope()
    if require"telescope" then
        return true
    end
    return false
end


---

CONFIG.initialize = function(opts)
    opts = opts or CONFIG.options

    -- init_path()

    if opts.default then
        -- nvim-cmake
        if opts.nvim_cmake then
        end
    end
end

return CONFIG
