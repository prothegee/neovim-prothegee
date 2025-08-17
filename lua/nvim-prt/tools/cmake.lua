local NVIM_CMAKE = {}

---

NVIM_CMAKE.file = {
    cmake_lists_txt = "CMakeLists.txt",
    cmake_presets_json = "CMakePresets.json",
    cmake_compile_commands_json = "compile_commands.json",

    nvim_cmake_json = "nvim-cmake.json"
}

NVIM_CMAKE.template = {
    nvim_cmake_json_content = [[
{
    "preset": 0,
    "preset_name": "debug"
}
    ]]
}

---

local function set_dot_nvim_cmake_json()
    local _prt = {
        _ = require"nvim-prt",
        nvim = require"nvim-prt.tools.nvim"
    }

    _prt.nvim.initialize()

    local destination = vim.fn.getcwd() .. "/.nvim/" .. NVIM_CMAKE.file.nvim_cmake_json

    if vim.uv.fs_statfs(destination) then
        vim.notify(destination .. " already exists", vim.log.levels.INFO)
        return
    end

    local file = io.open(destination, "w")

    if not file then
        vim.notify("failed to open " .. destination, vim.log.levels.ERROR)
        return
    end

    if not file:write(NVIM_CMAKE.template.nvim_cmake_json_content) then
        vim.notify("failed to write " .. destination, vim.log.levels.ERROR)
        return
    end

    if not file:close() then
        vim.notify("failed to close ".. destination, vim.log.levels.ERROR)
        return
    end
end

local function get_dot_nvim_cmake_json_data()
    local result = { preset = 0, preset_name = debug }

    local dot_nvim_cmake_json_file = vim.fn.getcwd() .. "/.nvim/" .. NVIM_CMAKE.file.nvim_cmake_json

    if not dot_nvim_cmake_json_file then
        vim.notify(dot_nvim_cmake_json_file .. " doesn't exists, try run Preset Init first", vim.log.levels.ERROR)
        return nil
    end

    local file, file_error = io.open(dot_nvim_cmake_json_file, "r")

    if not file then
        vim.notify("failed to open file " .. (file_error or "unknown error"), vim.log.levels.ERROR)
        return nil
    end

    local content, content_error = file:read("*a")

    if not content then
        vim.notify("failed to read content " .. (content_error or "unknown error"), vim.log.levels.ERROR)
        return nil
    end

    local close, close_error = file:close()

    if not close then
        vim.notify("failed to close " .. (close_error or "unknown error"), vim.log.levels.ERROR)
        return nil
    end

    content = content:gsub("//.-[\r\n]", "") -- remove comments

    local data_ok, data = pcall(vim.json.decode, content)

    if not data_ok then
        vim.notify("failed to decode content", vim.log.levels.ERROR)
        return nil
    end

    result = data

    return result
end

local function set_dot_nvim_cmake_json_data(preset, preset_name)
    local _prt = {
       json = require"nvim-prt.tools.json"
    }

    local dot_nvim_cmake_json_file = vim.fn.getcwd() .. "/.nvim/" .. NVIM_CMAKE.file.nvim_cmake_json

    if not dot_nvim_cmake_json_file then
        vim.notify("can't found .nvim/nvim-cmake.json in project root", vim.log.levels.ERROR)
        return false
    end

    local data = { preset = preset, preset_name = preset_name }
    local json = _prt.json.format_with_indent(data, 4)

    local file, file_error = io.open(dot_nvim_cmake_json_file, "w")

    if not file then
        vim.notify("failed to open file " .. (file_error or "unknown error"), vim.log.levels.ERROR)
        return false
    end

    local write, write_error = file:write(json)

    if not write then
        vim.notify("failed to write json " .. (write_error or "unknown error"), vim.log.levels.ERROR)
        return false
    end

    local close, close_error = file:close()

    if not close then
        vim.notify("fail to close file " .. (close_error or "unknown error"), vim.log.levels.ERROR)
        return false
    end

    return true
end

local function get_cmake_preset_data()
    local file  = io.open(vim.fn.getcwd() .. "/" .. NVIM_CMAKE.file.cmake_presets_json)

    if not file then
        vim.notify("failed to open CMakePresets.json, doesn't exists")
        return nil
    end

    local content = file:read("*a")
    file:close()

    content = content:gsub("//.-[\r\n]", "") -- remove comments

    local presets_ok, presets = pcall(vim.json.decode, content)

    if not presets_ok then
        vim.notify("failed to decode content as preset", vim.log.levels.ERROR)
        return nil
    end

    if not presets.configurePresets or type(presets.configurePresets) ~= "table" then
        vim.notify("failed to decode contents as presets", vim.log.levels.ERROR)
        return nil
    end

    local dot_nvim_cmake_json_data = get_dot_nvim_cmake_json_data()

    if not dot_nvim_cmake_json_data or not dot_nvim_cmake_json_data.preset then
        vim.notify("preset key not found", vim.log.levels.ERROR)
        return nil
    end

    local preset = dot_nvim_cmake_json_data.preset + 1

    if preset < 1 or preset > #presets.configurePresets then
        vim.notify("wrong preset index, (" .. preset .. ") out of range", vim.log.levels.ERROR)
        return nil
    end

    local data = presets.configurePresets[preset]

    if not data or type(data) ~= "table" then
        vim.notify("wrong preset data from preset index", vim.log.levels.ERROR)
        return nil
    end

    if not data.name then
        vim.notify("preset missing name key", vim.log.levels.ERROR)
        return nil
    end

    if not data.binaryDir then
        vim.notify("preset missing binaryDir key", vim.log.levels.ERROR)
        return nil
    end

    if dot_nvim_cmake_json_data.preset_name and data.name ~= dot_nvim_cmake_json_data.preset_name then
        vim.notify(string.format("preset name not match, cache=%s, preset=%s", dot_nvim_cmake_json_data.preset_name, data.name), vim.log.levels.ERROR)
        return nil
    end

    return data
end

---

NVIM_CMAKE.preset_init_hint = "NvimCmake: Preset Init"
function NVIM_CMAKE.preset_init()
    local _prt = {
        _ = require"nvim-prt"
    }

    local source = _prt._.dir .. "/template/" .. NVIM_CMAKE.file.cmake_presets_json

    if not vim.uv.fs_stat(source) then
        vim.notify("failed to read " .. source .. " template is missing", vim.log.levels.ERROR)
        return
    end
    set_dot_nvim_cmake_json()

    local file, file_error =  io.open(source, "r")

    if not file then
        vim.notify("failed to open " .. (file_error or "unknown error"), vim.log.levels.ERROR)
        return
    end

    local content, content_error = file:read("*a")

    if not content then
        vim.notify("failed to read content " .. (content_error or "unknown error"), vim.log.levels.ERROR)
        return
    end

    local destination = vim.fn.getcwd() .. "/" .. NVIM_CMAKE.file.cmake_presets_json

    local outfile, outfile_error = io.open(destination, "w")

    if not outfile then
        vim.notify("fail to write file " .. (outfile_error or "unknown error"), vim.log.levels.ERROR)
        return
    end

    local write, write_error = outfile:write(content)

    if not write then
        vim.notify("failed to write content " .. (write_error or "unknown error"), vim.log.levels.ERROR)
        outfile:close()
        return
    end

    local close, close_error = outfile:close()

    if not close then
        vim.notify("failed to close file " .. (close_error or "unknown error"), vim.log.levels.ERROR)
        return
    end
end

NVIM_CMAKE.preset_select_hint = "NvimCmake: Preset Select"
function NVIM_CMAKE.preset_select()
    local cmake_presets_json_file = vim.fn.getcwd() .. "/" .. NVIM_CMAKE.file.cmake_presets_json

    if not cmake_presets_json_file then
        vim.notify("can't found CMakePresets.json in project root", vim.log.levels.ERROR)
        return
    end

    local file, file_error = io.open(cmake_presets_json_file, "r")

    if not file then
        vim.notify("failed to read file " .. (file_error or "unknown error"), vim.log.levels.ERROR)
        return
    end

    local content, content_error = file:read("*a")

    if not content then
        vim.notify("failed to read content " .. (content_error or "unknown error"), vim.log.levels.ERROR)
        return
    end

    content = content:gsub("//.-[\r\n]", "") -- remove comments

    local data_ok, data = pcall(vim.json.decode, content)

    if not data_ok then
        vim.notify("failed to decode preset CMakePresets.json", vim.log.levels.ERROR)
        return
    end

    if not data.configurePresets then
        vim.notify("CMakePresets.json data doesn't has `configurePresets` key", vim.log.levels.ERROR)
        return
    end

    local presets = {}

    for index, preset in ipairs(data.configurePresets) do
        table.insert(presets, {
            index = index - 1, -- 0-based index
            name = preset.name,
            display_name = preset.displayName
        })
    end

    if #presets == 0 then
        vim.notify("no presets found for some reason", vim.log.levels.ERROR)
        return
    end

    local items = {}

    for _, preset in ipairs(presets) do
        table.insert(items, preset.display_name)
    end

    vim.ui.select(items, {
        prompt = "Select CMake Preset:",
        format_item = function(item)
            return item
        end
    }, function(choice, index)
        if not choice then return end

        local selected_preset = presets[index]

        if selected_preset then
            local success = set_dot_nvim_cmake_json_data(selected_preset.index, selected_preset.name)

            if success then
                vim.notify("selected preset: " .. selected_preset.display_name, vim.log.levels.INFO)
            end
        else
            vim.notify("invalid preset selection", vim.log.levels.ERROR)
        end
    end)
end

NVIM_CMAKE.project_clean_hint = "NvimCmake: Project Clean"
function NVIM_CMAKE.project_clean()
    local _prt = {
        nvim = require"nvim-prt.tools.nvim"
    }

    local preset = get_cmake_preset_data()

    if preset == nil then
        vim.notify("preset error when clean the project", vim.log.error.ERROR)
        return
    end

    local cache = {}

    if preset.cacheVariables then
        for key, val in pairs(preset.cacheVariables) do
            table.insert(cache, string.format("-D%s=%s", key, tostring(val)))
        end
    end

    local binary_dir = preset.binaryDir:gsub("${sourceDir}", vim.fn.getcwd())

    local cmake_cmd = string.format(
        "cmake --build %s --target clean && rm -rf %s/*", -- non-unix style will fucked up
        binary_dir, binary_dir
    )

    _prt.nvim.create_terminal(cmake_cmd, "NvimCmake: Project Clean, Succeed", "NvimCmake: Project Clean, Failed", 0.3)
    -- _prt.nvim.create_floating_terminal(cmake_cmd, "NvimCmake: Project Clean", 0.9, 0.9, false, "minimal", "rounded", "center")
end

NVIM_CMAKE.project_configure_hint = "NvimCmake: Project Configure"
function NVIM_CMAKE.project_configure()
    local _prt = {
        nvim = require"nvim-prt.tools.nvim"
    }

    local preset = get_cmake_preset_data()

    if preset == nil then
        vim.notify("preset error", vim.log.levels.ERROR)
        return
    end

    local cache_vars = {}

    if not preset.cacheVariables then
        vim.notify("preset cacheVariables error", vim.log.levels.ERROR)
        return
    end

    for key, val in pairs(preset.cacheVariables) do
        table.insert(cache_vars, string.format("-D%s=%s", key, tostring(val)))
    end

    local binary_dir = preset.binaryDir:gsub("${sourceDir}", vim.fn.getcwd())

    local cmake_cmd = string.format(
        "cmake -G\"%s\" -S\"%s\" -B\"%s\" %s",
        preset.generator,
        vim.fn.getcwd(),
        binary_dir,
        table.concat(cache_vars, " ")
    )

    _prt.nvim.create_terminal(cmake_cmd, "NvimCmake: Project Configure, Succeed", "NvimCmake: Project Configure, Failed", 0.3)
end

NVIM_CMAKE.project_configure_build_hint = "NvimCmake: Project Configure Build"
function NVIM_CMAKE.project_configure_build()
    local _prt = {
        _ = require"nvim-prt",
        nvim = require"nvim-prt.tools.nvim"
    }

    local preset = get_cmake_preset_data()

    if preset == nil then
        vim.notify("preset error", vim.log.levels.ERROR)
        return
    end

    local cache_vars = {}

    if not preset.cacheVariables then
        vim.notify("preset cacheVariables error", vim.log.levels.ERROR)
        return
    end

    for key, val in pairs(preset.cacheVariables) do
        table.insert(cache_vars, string.format("-D%s=%s", key, tostring(val)))
    end

    local binary_dir = preset.binaryDir:gsub("${sourceDir}", vim.fn.getcwd())

    local symlink = function()
        local symlinkdel1, symlinkdel2 = "", ""
        local compile_commands_dir_file = vim.fn.getcwd() .. "/" .. binary_dir .. "/" .. NVIM_CMAKE.file.cmake_compile_commands_json
        local compile_commands_root_file = vim.fn.getcwd() .. "/" .. NVIM_CMAKE.file.cmake_compile_commands_json

        if _prt.nvim.os.windows then
            if io.open(vim.fn.getcwd() .. "/" .. compile_commands_dir_file, "r") ~= nil then
                symlinkdel1 = "del /f /q " .. compile_commands_dir_file .. ";"
            end
            if io.open(vim.fn.getcwd() .. "/" .. compile_commands_root_file, "r") ~= nil then
                symlinkdel2 = "del /f /q " .. compile_commands_root_file .. ";"
            end

            return string.format("%s%smklink %s/%s; ", symlinkdel1, symlinkdel2, binary_dir, NVIM_CMAKE.file.cmake_compile_commands_json)
        else
            if io.open(vim.fn.getcwd() .. "/" .. compile_commands_dir_file, "r") ~= nil then
                symlinkdel1 = "rm -rf " .. compile_commands_dir_file .. ";"
            end
            if io.open(vim.fn.getcwd() .. "/" .. compile_commands_root_file, "r") ~= nil then
                symlinkdel2 = "rm -rf " .. compile_commands_root_file .. ";"
            end

            return string.format("ln -s %s/%s; ", symlinkdel1, symlinkdel2, binary_dir, NVIM_CMAKE.file.cmake_compile_commands_json)
        end
    end

    local cmake_cmd = string.format(
        "%scmake --build \"%s\"",
        symlink(),
        binary_dir
    )

    _prt.nvim.create_terminal(cmake_cmd, "NvimCmake: Project Configure Build, Succeed", "NvimCmake: Project Configure Build, Failed", 0.3)
end

---

NVIM_CMAKE.cmd = {
    nvim_cmake_preset_init = "NvimCmakePresetInit",
    nvim_cmake_preset_select = "NvimCmakePresetSelect",
    nvim_cmake_project_clean = "NvimCmakeProjectClean",
    nvim_cmake_project_configure = "NvimCmakeProjectConfigure",
    nvim_cmake_project_configure_build = "NvimCmakeProjectConfigureBuild",
}

---

vim.api.nvim_create_user_command(
    NVIM_CMAKE.cmd.nvim_cmake_preset_init,
    NVIM_CMAKE.preset_init,
    {
        desc = NVIM_CMAKE.preset_init_hint
    }
)
vim.api.nvim_create_user_command(
    NVIM_CMAKE.cmd.nvim_cmake_preset_select,
    NVIM_CMAKE.preset_select,
    {
        desc = NVIM_CMAKE.preset_select_hint
    }
)
vim.api.nvim_create_user_command(
    NVIM_CMAKE.cmd.nvim_cmake_project_clean,
    NVIM_CMAKE.project_clean,
    {
        desc = NVIM_CMAKE.project_clean_hint
    }
)
vim.api.nvim_create_user_command(
    NVIM_CMAKE.cmd.nvim_cmake_project_configure,
    NVIM_CMAKE.project_configure,
    {
        desc = NVIM_CMAKE.preset_configure_hint
    }
)
vim.api.nvim_create_user_command(
    NVIM_CMAKE.cmd.nvim_cmake_project_configure_build,
    NVIM_CMAKE.project_configure_build,
    {
        desc = NVIM_CMAKE.project_configure_build_hint
    }
)

---

return NVIM_CMAKE
