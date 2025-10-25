local SNPPTS = {}

---

-- initialize snippets table
SNPPTS.snippets = {}

---

-- next: c
-- next: go
-- next: cpp
-- next: lua
-- next: rust
-- next: cmake
-- next: html
-- next: svelte
-- next: javascript
-- next: typescript

---

--[[
TODO:
- DO NOT USE ANY PLUGIN!
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

---

return SNPPTS

