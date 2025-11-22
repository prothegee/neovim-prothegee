local SNPPTS = {}

--[[

# SNPPTS
SNiPPeTS

--]]

---

-- initialize snippets table
SNPPTS.snippets = {}

---

--[[
TODO:
- when snippet is expand and found $n (n is number):
    - store that, so the state need to be able to change arg of that in $n, i.e
        ```
        struct $1 {
            // TODO
        }; // struct $1
        ```
    - when typing, the first $n all will be replace as long when typing
    - if there's more thatn 1 $n, then when press tab, it should go to next
    - if there's no more, exit the state of snippet $n
    - if ctrl+e pressed, exit the state if snippet $n so no need to
    - so from
    ```
    struct $1 {
        // TODO
    }; // struct $1
    ```
    - become
    ```
    struct my_typing_result_in_insert_mode {
        // TODO
    }; // struct my_typing_result_in_insert_mode 
    ```
--]]
function SNPPTS.get_all_snippets_for_filetype()
    local filetype = vim.bo.filetype
    if filetype == "" then
        return {}
    end

    local my_dir = require("nvim-prt").dir
    local snippet_file = my_dir .. "/snippets/" .. filetype .. ".json"

    local ok, stat_res = pcall(vim.loop.fs_stat, snippet_file)
    if not ok or not stat_res then
        return {}
    end

    local lines = vim.fn.readfile(snippet_file)
    if #lines == 0 then
        return {}
    end

    local content = table.concat(lines, "\n")
    local snippets, _ = vim.json.decode(content)
    if not snippets then
        return {}
    end

    if type(snippets) ~= "table" or snippets[1] == nil then
        return {}
    end

    return snippets
end

---

return SNPPTS

