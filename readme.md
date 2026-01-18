# tailwind-hover.nvim

View all applied Tailwind CSS values on an element.

## Installation

```lua
-- Using lazy.nvim package manager
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
