# tailwind-hover.nvim

Shows consolidated Tailwind CSS styles applied to the element under the cursor.

<img src="./assets/screenshot.png" />

## Usage

It behaves just like the default `lsp.hover` feature.

Choose your preferred shortcut to issue the command `TailwindHover`. Our choice is `<leader>K`, but it's not set by default, it needs your configuration.

Press the shortcut on any `class` (or `className`) attribute's value containing Tailwind CSS classes and it will open the LSP floating window with the list of all TW classes and their corresponding CSS statements. Any classes unknown to TW will be listed last.

Press the shortcut again, while the floating preview window is open, and it will focus it (just like the default `K` behavior).

## Installation

### Lazy

```lua
{
    "ruicsh/tailwind-hover.nvim",
    keys = {
        { "<leader><s-k>", "<cmd>TailwindHover<cr>", desc = "Tailwind: Hover" },
    },
    opts = {},
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
}
```

## Options

```lua
opts = {
    border = vim.o.winborder, -- Floating window border
    title = "", -- Title of floating window
    fallback_to_lsp_hover = false, -- Fallback to native vim.lsp.buf.hover
}
```

### Keymaps

There's no shortcut assigned by this plugin. You'll need to assign your own to `<cm>TailwindHover<cr>`.

A possible setup is to use the default `K` for `vim.lsp.buf.hover` so that you use the same shortcut for all `lsp.hover` calls. For this to work, option `fallback_to_lsp_hover` needs to be set to `true` so that it calls `lsp.hover` as a fallback when the cursor is not placed on an attrtibute's value with name `class` or `className`.

## Supported languages

The currently supported languages are the following:

- typescriptreact
- typescript
- astro
- vue
- svelte
- templ
- html

Uses HTML parser as fallback.

## Integrations

### [hover.nvim](https://github.com/lewis6991/hover.nvim)

```lua
require('hover').config({
  providers = {
    "tailwind-hover.providers.hover",
  }
})
```

## Acknowledgments

Inspired by [tw-values.nvim](https://github.com/MaximilianLloyd/tw-values.nvim)
