local CMPLTN = {}

local COMPLETION_DELAY = 150 -- in milliseconds

---

local _buf_default_completion = function(buffer)
    vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
    -- completion using default
    vim.bo[buffer].omnifunc = "v:lua.vim.lsp.omnifunc"
    -- completion using nvim-prt.cmpltn
    -- vim.bo[buffer].omnifunc = "v:lua._prt_fuzzy_completion"
end

local _completion_trigger = function(client, buffer)
    vim.opt.shortmess:append("c")
    _buf_default_completion(buffer)
end

---

--[[
TODO:
- DO NOT USE ANY PLUGINS!
- integrate with nvim-prt.snppts
- async, body completion should be expand from:
    - <C-x><C-o>
    - nvim-prt.snppts
- if there are any parameters of $n (n is number):
    - store it before expand
--]]
_G._prt_fuzzy_completion = function()
    local _prt = {
        _snippets = require"nvim-prt.snppts"
    }

    -- what?
end

---

-- default capabilities
CMPLTN.capabilities = vim.lsp.protocol.make_client_capabilities()
CMPLTN.capabilities.textDocument.completion = {
    contextsupport = true,
    dynamicregistration = true,
    completionitem = {
        tagsupport = { valueset = { 1 } },
        snippetsupport = true,
        resolvesupport = {
            properties = { "detail", "documentation", "additionalTextEdits", "snippets" }
        },
        preselectsupport = true,
        deprecatedsupport = true,
        labeldetailssupport = true,
        documentationformat = { "markdown", "plaintext" },
        insertreplacesupport = true,
        inserttextmodesupport = {
            valueset = { 1, 2 }
        },
        commitcharacterssupport = true,
    },
}

---

-- on init
function CMPLTN.on_init(client, buffer)
    if client:supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semantictokensprovider = nil
    end
end

-- on attach
function CMPLTN.on_attach(client, buffer)
    _completion_trigger(client, buffer)
end

---

-- default completion
function CMPLTN.default_completion(buffer)
    _buf_default_completion(buffer)
end

-- # default auto command
-- ---
-- # note
-- * will reject if current server not supported from supported_lsps param
function CMPLTN.default_autocmd(supported_lsps)
    local _prt = {
        nvim = require"nvim-prt.tools.nvim"
    }

    local rejected = true

    if next(supported_lsps) then
        for _, lsp in pairs(supported_lsps) do
            if lsp == _prt.nvim.get_current_lsp_server_name() then
                rejected = false
                break
            end
        end
    end

    -- BufEnter
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        callback = function(args)
            if rejected then return end

            local buffer = args.buf

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            CMPLTN.default_completion(buffer)
        end
    })
    -- LspAttach
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            if rejected then return end

            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            CMPLTN.on_attach(client, buffer)
        end
    })
    -- InsertCharPre
    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = function(args)
            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.bo[buffer].omnifunc ~= "" and vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        "<C-x><C-o>",
                        true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
    -- TextChangedI
    vim.api.nvim_create_autocmd("TextChangedI", {
        callback = function(args)
            if rejected then return end

            local buffer = args.buf
            local buffer_name = vim.api.nvim_buf_get_name(buffer)

            if not vim.api.nvim_buf_is_valid(buffer) then return end
            if buffer_name == "" then return end

            if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
                vim.defer_fn(function()
                    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(
                        "<C-x><C-o>",
                        true, true, true
                    ), "n")
                end, COMPLETION_DELAY)
            end
        end
    })
end

---

return CMPLTN
