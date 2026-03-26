local M = {}
local config = require("claude-completion.config")
local ui = require("claude-completion.ui")
local api = require("claude-completion.api")

local timer = nil

function M.setup(opts)
    config.setup(opts)

    -- Commands
    vim.api.nvim_create_user_command("ClaudeComplete", function()
        M.trigger_completion()
    end, {})

    vim.api.nvim_create_user_command("ClaudeClear", function()
        ui.clear_suggestion(0)
    end, {})

    -- Autocommands for automatic completion
    local group = vim.api.nvim_create_augroup("ClaudeCompletion", { clear = true })
    
    vim.api.nvim_create_autocmd({ "InsertCharPre", "TextChangedI" }, {
        group = group,
        callback = function()
            M.debounced_trigger()
        end,
    })

    vim.api.nvim_create_autocmd({ "CursorMovedI", "InsertLeave" }, {
        group = group,
        callback = function()
            ui.clear_suggestion(0)
        end,
    })

    -- Keybindings
    local keymaps = config.options.keymaps
    if keymaps.accept then
        vim.keymap.set("i", keymaps.accept, function()
            local suggestion = ui.get_current_suggestion()
            if suggestion then
                vim.schedule(function()
                    local cursor = vim.api.nvim_win_get_cursor(0)
                    ui.accept_suggestion(0, cursor[1] - 1, cursor[2])
                end)
                return ""
            else
                -- Fallback to default tab behavior if no suggestion
                return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
            end
        end, { expr = true, silent = true })
    end

    if keymaps.dismiss then
        vim.keymap.set("i", keymaps.dismiss, function()
            ui.clear_suggestion(0)
        end, { silent = true })
    end

    if keymaps.trigger then
        vim.keymap.set("i", keymaps.trigger, function()
            M.trigger_completion()
        end, { silent = true })
    end
end

function M.debounced_trigger()
    if timer then
        timer:stop()
        timer:close()
    end
    
    timer = vim.loop.new_timer()
    timer:start(config.options.debounce_ms, 0, vim.schedule_wrap(function()
        if vim.api.nvim_get_mode().mode == "i" then
            M.trigger_completion()
        end
    end))
end

function M.trigger_completion()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1
    local col = cursor[2]

    -- Get surrounding context
    -- For now, get last 50 lines as context
    local start_line = math.max(0, line - 50)
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, line + 1, false)
    
    -- Current line content up to the cursor
    local current_line = lines[#lines]
    lines[#lines] = current_line:sub(1, col)
    
    local context = table.concat(lines, "\n")
    local prompt = string.format("Complete the following code starting from the cursor position:\n\n```%s\n%s\n```", 
        vim.bo.filetype, context)

    api.get_completion(prompt, function(suggestion)
        if suggestion and suggestion ~= "" then
            vim.schedule(function()
                -- Ensure we are still at the same position before showing
                local current_cursor = vim.api.nvim_win_get_cursor(0)
                if current_cursor[1] == cursor[1] and current_cursor[2] == cursor[2] then
                    ui.show_suggestion(bufnr, line, col, suggestion)
                end
            end)
        end
    end)
end

return M
