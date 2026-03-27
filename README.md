# claude-completion.nvim

GitHub Copilot-like code completion for NeoVim using the `claude` CLI.

## Requirements

- NeoVim (latest version recommended)
- `claude` CLI installed and authenticated.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "goropikari/claude-completion.nvim",
    opts = {
        model = "sonnet", -- or "haiku"
        debounce_ms = 500,
        keymaps = {
            accept = "<Tab>",
            dismiss = "<C-e>",
        },
        -- Enable debug_mode to log raw Claude CLI responses and stderr
        debug_mode = false,
        -- Specify the path to the Claude CLI executable if it's not in your PATH
        claude_cli_path = "claude",
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
