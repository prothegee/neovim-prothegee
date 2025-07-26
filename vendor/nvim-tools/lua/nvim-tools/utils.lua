local UTILS = {}

---

function UTILS.get_nvim_tools_dir()
    local info = debug.getinfo(1, "S")
    local script_path = info.source:sub(2)
    return vim.fn.fnamemodify(script_path, ":p:h")
end

function UTILS.get_nvim_tools_template_dir()
    return vim.fn.fnamemodify(UTILS.get_nvim_tools_dir(), ":h:h") .. "/template/"
end

---

function UTILS.read_json_file(file_path)
    if not vim.loop.fs_stat(file_path) then
        return nil
    end

    local file = io.open(file_path, "r")

    if not file then
        return nil
    end

    local content = file:read("*a")

    file:close()

    local ok, data = pcall(vim.json.decode, content)

    if not ok then
        return nil
    end

    return data
end

function UTILS.write_json_file(file_path, data)
    local content = require"nvim-tools.format".json_with_indent(data, 4)
    UTILS.write_file(file_path, content)
end

function UTILS.write_file(file_path, content)
    local lines = vim.split(content, "\n")
    vim.fn.writefile(lines, file_path)
end

---

return UTILS
