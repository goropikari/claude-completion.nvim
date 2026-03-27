local M = {}
local config = require("claude-completion.config")

local last_job_id = nil

function M.get_completion(prompt, callback)
	if last_job_id then
		vim.fn.jobstop(last_job_id)
		last_job_id = nil
	end

	local model = config.options.model or "haiku"
	local system_prompt = config.options.system_prompt
	local cli_path = config.options.claude_cli_path or "claude"

	-- Construct the command
	local cmd = {
		cli_path,
		"--print",
		"--bare",
		"--model",
		model,
		"--system-prompt",
		system_prompt,
		prompt,
	}

	local output = ""
	last_job_id = vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data, _)
			if data then
				output = table.concat(data, "\n")
			end
		end,
		on_stderr = function(_, data, _)
			if data and #data > 1 then
				-- Use debug_print for stderr messages if debug_mode is enabled
				config.debug_print("Claude CLI stderr: " .. table.concat(data, "\n"))
			end
		end,
		on_exit = function(_, exit_code, _)
			last_job_id = nil
			if exit_code == 0 then
				-- Log the raw response from the CLI only if debug_mode is enabled
				config.debug_print("Raw Claude Response:\n" .. output)

				-- Try to extract content from markdown code blocks
				local code_block = output:match("```[%w_-]*\n?(.*)```")
				if code_block then
					output = code_block
				end

				-- Clean up output (sometimes it might contain extra spaces or markers)
				output = output:gsub("^%s+", ""):gsub("%s+$", "")
				callback(output)
			else
				-- Log error if debug_mode is enabled
				config.debug_print(string.format("Claude CLI exited with code %d. Raw output: %s", exit_code, output))
				callback(nil)
			end
		end,
	})
end

return M
