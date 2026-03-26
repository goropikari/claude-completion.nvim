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
    dependencies = { "nvim-lua/plenary.nvim" }, -- Optional, but useful for some extensions
    config = function()
        require('claude-completion').setup({
            model = "sonnet", -- or "haiku"
            debounce_ms = 500,
            keymaps = {
                accept = "<Tab>",
                dismiss = "<C-e>",
            }
        })
    end
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
