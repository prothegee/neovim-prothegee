local JSON = {}

function JSON.format_with_indent(data, indent_space)
    local json = vim.json.encode(data)
    local indent = string.rep(" ", indent_space)

    local level = 0
    local result = ""
    local in_string = false

    for i = 1, #json do
        local char = json:sub(i, i)

        -- string literal, skip formating inside string
        if char == '"' and json:sub(i-1, i-1) ~= "\\" then
            in_string = not in_string
        end

        if not in_string then
            if char == "{" or char == "[" then
                -- opening brace, increase indent
                result = result .. char .. "\n" .. string.rep(indent, level + 1)
                level = level + 1
            elseif char == "}" or char == "]" then
                -- closing brance, decrease indent
                level = math.max(level - 1, 0)
                result = result .. "\n" .. string.rep(indent, level) .. char
            elseif char == "," then
                -- comma, new line with current indent
                result = result .. char .. "\n" .. string.rep(indent, level)
            elseif char == ":" then
                -- colon, add space after
                result = result .. char .. " "
            else
                -- other character
                result = result .. char
            end
        else
            -- inside string, add character as is
            result = result .. char
        end
    end

    return result
end

return JSON
