# claude-completion.nvim

GitHub Copilot-like code completion for NeoVim using the `claude` CLI.

## Requirements
- NeoVim (latest version recommended)
- `claude` CLI installed and authenticated.

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "your-username/claude-completion.nvim",
    -- Optional, but useful for some extensions
-- In your lazy.nvim setup:
{
    "your-username/claude-completion.nvim",
    -- Configuration options are passed directly to the setup function via the 'opts' table
    opts = {
        model = "sonnet", -- or "haiku"
        debounce_ms = 500,
        keymaps = {
            accept = "<Tab>",
            dismiss = "<C-e>",
        }
    }
}
}
```

## Features
- **Ghost Text**: Suggestions appear as you type.
- **Asynchronous**: Completions are fetched in the background without blocking NeoVim.
- **Smart Trigger**: Automatically triggers after a period of typing inactivity.

## Keybindings (Default)
- `<Tab>`: Accept the current suggestion.
- `<C-e>`: Dismiss the suggestion.
- `<C-Space>`: Manually trigger completion.

## Commands
- `:ClaudeComplete`: Manually trigger completion.
- `:ClaudeClear`: Clear current suggestion.
