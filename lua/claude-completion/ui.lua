local M = {}

local ns_id = vim.api.nvim_create_namespace("claude-completion")
local current_suggestion = nil

---@param bufnr number
---@param line number
---@param col number
---@param text string
function M.show_suggestion(bufnr, line, col, text)
    M.clear_suggestion(bufnr)
    if not text or text == "" then return end

    current_suggestion = text
    local lines = vim.split(text, "\n")
    
    -- First line as inline virtual text
    local first_line = lines[1]
    local other_lines = {}
    for i = 2, #lines do
        table.insert(other_lines, { { lines[i], "Comment" } })
    end

    local opts = {
        virt_text = { { first_line, "Comment" } },
        virt_text_pos = "overlay",
        virt_lines = #other_lines > 0 and other_lines or nil,
        -- Set to high priority so it stays visible
        priority = 100,
    }

    -- Adjust column to current cursor position to show after the last character
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, col, opts)
end

---@param bufnr number
function M.clear_suggestion(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    current_suggestion = nil
end

function M.get_current_suggestion()
    return current_suggestion
end

---@param bufnr number
---@param line number
---@param col number
function M.accept_suggestion(bufnr, line, col)
    if not current_suggestion then return end

    local text = current_suggestion
    M.clear_suggestion(bufnr)

    -- Insert the text at the cursor position
    -- Note: This is a simple insertion. We might need to adjust for indentation.
    local lines = vim.split(text, "\n")
    
    -- Insert the first line at the cursor
    local current_line_text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
    local new_line = current_line_text:sub(1, col) .. lines[1] .. current_line_text:sub(col + 1)
    vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { new_line })
    
    -- Insert subsequent lines
    if #lines > 1 then
        local rest_lines = {}
        for i = 2, #lines do
            table.insert(rest_lines, lines[i])
        end
        vim.api.nvim_buf_set_lines(bufnr, line + 1, line + 1, false, rest_lines)
    end
    
    -- Move cursor to the end of the completion
    local last_line = line + #lines - 1
    local last_col = #lines == 1 and (col + #lines[1]) or #lines[#lines]
    vim.api.nvim_win_set_cursor(0, { last_line + 1, last_col })
end

return M
