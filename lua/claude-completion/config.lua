local M = {}

local default_config = {
	model = "haiku",
	debounce_ms = 500,
	keymaps = {
		accept = "<Tab>",
		dismiss = "<C-e>",
		trigger = "<C-Space>",
	},
	system_prompt = [[You are a code completion assistant. Given the surrounding code context, provide ONLY the code that should follow the cursor position.
Do not include any explanations, Markdown formatting, or additional context.
If the completion is multi-line, return multiple lines.
If there is nothing meaningful to complete, return nothing.]],
	-- Option to control debug logging
	debug_mode = false,
	-- Path to the Claude CLI executable
	claude_cli_path = "claude",
}

M.options = {}

function M.setup(user_options)
	M.options = vim.tbl_deep_extend("force", default_config, user_options or {})
end

--- A debug print function that only outputs if debug_mode is enabled.
-- @param message string The message to print.
function M.debug_print(message)
	if M.options.debug_mode then
		vim.print(message)
	end
end

return M
