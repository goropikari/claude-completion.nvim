local M = {}
local config = require("claude-completion.config")

local last_job_id = nil

function M.get_completion(prompt, callback)
	if last_job_id then
		vim.fn.jobstop(last_job_id)
		last_job_id = nil
	end

	local model = config.options.model or "sonnet"
	local system_prompt = config.options.system_prompt

	local cmd = {
		"claude",
		"--print",
		"--bare",
		"--max-thinking-tokens",
		"0",
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
				-- Log or handle errors if necessary
			end
		end,
		on_exit = function(_, exit_code, _)
			last_job_id = nil
			if exit_code == 0 then
				-- Try to extract content from markdown code blocks
				local code_block = output:match("```[%w_-]*\n?(.*)```")
				if code_block then
					output = code_block
				end

				-- Clean up output (sometimes it might contain extra spaces or markers)
				output = output:gsub("^%s+", ""):gsub("%s+$", "")
				callback(output)
			else
				callback(nil)
			end
		end,
	})
end

return M
