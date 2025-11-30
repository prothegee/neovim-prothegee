# neovim-prothegee

__*NOTE:*__
- using vim.pack
- minimalism attempt
- most keymap are default [except](#configured keymap or shortcut])
- meant to use for 0.12.* or above

<br>

## note

- configured for:
    - c, c++, cmake
    - ^rust, ^go, ^zig, ^js, ^ts,
    - ^markdown, ^sql
    - ^html, ^css, ^scss, ^htmx
- check [this file](./lua/settings/lsp.lua) for lsp/s
- check [this file](./lua/settings/treesitter.lua) for treesitters

<br>

## used plugins

- [hlchunk](https://github.com/shellRaining/hlchunk.nvim)
- [gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [lspconfig](https://github.com/neovim/nvim-lspconfig)
- [onedarkpro](https://github.com/olimorris/onedarkpro.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [render-markdown](https://github.com/MeanderingProgrammer/render-markdown.nvim)

see [this file](./lua/plugins/init.lua) for more information

<br>

## modules

- [slr](lua/nvim-prt/slr.lua)

- [xplrr](lua/nvim-prt/xplrr.lua)

- [snppts](lua/nvim-prt/snppts.lua)

<br>

## configured keymap or shortcut

- `<C-A-t>` e.q. `ctrl+altt+t`:
    - open/close bottom terminal

- `<C-A-S-t>` e.q. `ctrl+alt+shift+t`:
    - create empty new tab

- `<C-x><C-p>`:
    - global fuzzy completion

- `<C-x><C-[>`:
    - global snippet from snppts

<br>

---

###### end of readme

