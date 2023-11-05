local Popup = require("nui.popup")
local utils = require("neoai2.utils")

local ChatOutput = Popup:extend("ChatOutput")

function ChatOutput:init(provider, model, popup_options)
    local title = "NeoAI2"

    -- TODO: Change to supplying these indirectly through the Layout
    local provider_part = "Provider: " .. provider
    local model_part = "(" .. model .. ")"
    local bottom_text = provider_part .. " " .. model_part

    local opts = {
        enter = false,
        focusable = true,
        border = {
            style = "rounded",
            text = {
                top = " " .. title .. " ",
                top_align = "center",
                bottom = " " .. bottom_text .. " ",
                bottom_align = "left",
            },
        },
    }
    local options = vim.tbl_deep_extend("force", popup_options or {}, opts)

    ChatOutput.super.init(self, options)
end

function ChatOutput:clear()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end

function ChatOutput:scroll_bottom()
    local output_line_count = vim.api.nvim_buf_line_count(self.bufnr)
    vim.api.nvim_win_set_cursor(self.winid, { output_line_count, 0 })
end

function ChatOutput:append_lines(lines)
    local start_idx = -1

    -- If the buffer is empty we want to start at the first line
    if utils.is_buf_empty(self.bufnr) then
        start_idx = 0
    end

    vim.api.nvim_buf_set_lines(self.bufnr, start_idx, -1, false, lines)

    self:scroll_bottom()
end

function ChatOutput:append_string(str)
    str = str or ""
    local lines = vim.split(str, "\n", { plain = true })

    local last_line = vim.api.nvim_buf_get_lines(self.bufnr, -2, -1, false)[1]

    lines[1] = last_line .. lines[1]

    vim.api.nvim_buf_set_lines(self.bufnr, -2, -1, false, lines)

    self:scroll_bottom()
end

function ChatOutput:append_message(message)
    if message.role == "user" then
        self:append_lines({ "You:", "" })
    elseif message.role == "assistant" then
        self:append_lines({ "AI:", "" })
    elseif message.role == "system" then
        self:append_lines({ "System:", "" })
    end

    self:append_string(message.content .. "\n")
end

function ChatOutput:render_snapshot(snapshot)
    self:clear()

    -- TODO: Set the title

    for _, message in ipairs(snapshot.messages) do
        self:append_message(message)
    end
end

return ChatOutput
