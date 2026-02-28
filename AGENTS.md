# AGENTS.md - Agent Guidelines for tailwind-hover.nvim

## Project Overview

A Neovim plugin that shows consolidated Tailwind CSS styles applied to the element under the cursor. It uses treesitter to parse the AST and the Tailwind CSS LSP to resolve class names to their CSS definitions.

## Project Structure

```
.
├── lua/tailwind-hover/
│   ├── init.lua          # Main entry point, setup and hover command
│   ├── lsp.lua           # Tailwind LSP interaction
│   ├── treesitter.lua    # Treesitter AST parsing for class attributes
│   ├── hover.lua         # Floating window display
│   ├── utils.lua         # Utility functions
│   └── providers/
│       └── hover.lua     # hover.nvim integration provider
├── plugin/tailwind-hover.lua  # Plugin initialization, registers :TailwindHover command
├── doc/tailwind-hover.txt     # Neovim help documentation
└── readme.md
```

## Technology Stack

- **Language**: Lua (LuaJIT)
- **Neovim API**: `vim.api.*`, `vim.treesitter.*`, `vim.lsp.*`
- **Dependencies**: nvim-treesitter (runtime)

## Commands

This project has no formal build, lint, or test commands. It is a pure Neovim plugin distributed via package managers (e.g., Lazy, Packer).

### Running the Plugin

To test changes:
1. Add the plugin to your Neovim config
2. Open a file with Tailwind CSS classes (e.g., `.html`, `.tsx`)
3. Run `:TailwindHover` or use your mapped key

### Manual Linting (if needed)

```bash
# Check Lua syntax
luac -p lua/tailwind-hover/*.lua

# Using luacheck (install first: luarocks install luacheck)
luacheck lua/tailwind-hover/
```

## Code Style Guidelines

### Formatting

- **Indentation**: 2 spaces (no tabs)
- **Line length**: Soft limit ~100 characters
- **Trailing whitespace**: Avoid

### Naming Conventions

- **Files**: snake_case (e.g., `treesitter.lua`, `hover.lua`)
- **Variables/functions**: snake_case (e.g., `get_tw_classes_at_cursor`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `ENABLED_FILETYPES`)
- **Modules**: `local M = {}` pattern, return `M` at end

### Module Pattern

```lua
local M = {}

-- Public function
function M.public_function(arg)
  -- implementation
end

-- Private function (local)
local function private_helper()
  -- implementation
end

return M
```

### Imports

Use `require` for module imports:
```lua
local hover = require("tailwind-hover.hover")
local utils = require("tailwind-hover.utils")
```

### Error Handling

- Use `vim.notify(message, vim.log.levels.ERROR)` for user-visible errors
- Use `print()` sparingly for debugging
- Return early on error conditions
- Check for nil values explicitly before using results from vim APIs

```lua
local node = vim.treesitter.get_node({ bufnr = bufnr })
if node == nil then
  return {}
end
```

### Tables/Arrays

- Use `#table + 1` pattern for appending:
```lua
table.insert(unknown_classes, #unknown_classes + 1, tw_class.str)
```

- Use `ipairs` for arrays, `pairs` for dictionaries:
```lua
for _, value in ipairs(t) do end
for key, value in pairs(t) do end
```

### vim API Usage

- Use `vim.api.*` functions over legacy `vim.*` where available
- Access Neovim globals via `vim.o`, `vim.bo`, `vim.wo`
- Use `vim.tbl_*` utilities for table operations

### Comments

- Use comments to explain non-obvious logic
- Keep comments concise and in English
- Example: `-- Get the tailwindcss LSP client`

### Neovim Specific Patterns

#### Creating User Commands
```lua
vim.api.nvim_create_user_command("TailwindHover", function()
  require("tailwind-hover").hover()
end, {})
```

#### Creating Autocmds
```lua
vim.api.nvim_create_autocmd("WinClosed", {
  once = true,
  callback = function(args)
    -- handler
  end,
})
```

#### Treesitter Queries
```lua
local node = vim.treesitter.get_node({ bufnr = bufnr, ignore_injections = false })
local node_type = node:type()
local text = vim.treesitter.get_node_text(node, bufnr)
```

#### LSP Integration
```lua
local clients = vim.lsp.get_clients({ name = "tailwindcss" })
vim.lsp.util.open_floating_preview(contents, "css", options)
```

## Testing

There are currently no automated tests. To manually test:

1. Open a file with Tailwind classes (e.g., HTML, TSX, Vue, Svelte)
2. Place cursor on a `class="..."` or `className="..."` attribute value
3. Run `:TailwindHover` command
4. Verify the floating window shows CSS definitions

## Common Tasks

### Adding a New Language Support

1. Update `ENABLED_FILETYPES` in `lua/tailwind-hover/providers/hover.lua`
2. Verify treesitter parser exists for that filetype
3. Test parsing works for the new filetype

### Modifying Hover Display

Edit `lua/tailwind-hover/hover.lua` - handles floating window creation and content formatting.

### Modifying LSP Resolution

Edit `lua/tailwind-hover/lsp.lua` - handles communication with Tailwind CSS language server.

## Documentation

- Update `doc/tailwind-hover.txt` for Neovim help documentation
- Update `readme.md` for user-facing documentation
- Follow existing documentation style when adding new sections
