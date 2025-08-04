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

function NVIM_CMAKE.nvim_cmake_init()
    local destination = vim.fn.getcwd .. "/.nvim/" .. NVIM_CMAKE.file.nvim_cmake_json

    if vim.uv.fs_statfs(destination) then
        vim.schedule(function()
            vim.notify(destination .. " already exists", vim.log.levels.INFO)
        end)
        return
    end

    local file = io.open(destination, "w")

    if not file then
    end
end

---

NVIM_CMAKE.preset_init_hint = "NvimCmake: Preset Init"
function NVIM_CMAKE.preset_init()
    print("TODO: NVIM_CMAKE.preset_init")
end

NVIM_CMAKE.preset_select_hint = "NvimCmake: Preset Select"
function NVIM_CMAKE.preset_select()
    print("TODO: NVIM_CMAKE.preset_select")
end

NVIM_CMAKE.project_configure_hint = "NvimCmake: Project Configure"
function NVIM_CMAKE.project_configure()
    print("TODO: NVIM_CMAKE.project_configure")
end

NVIM_CMAKE.project_configure_build_hint = "NvimCmake: Project Configure Build"
function NVIM_CMAKE.project_configure_build()
    print("TODO: NVIM_CMAKE.project_configure_build")
end

NVIM_CMAKE.project_clean_hint = "NvimCmake: Project Clean"
function NVIM_CMAKE.project_clean()
    print("TODO: NVIM_CMAKE.project_clean")
end

---

return NVIM_CMAKE
