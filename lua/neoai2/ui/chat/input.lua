local Popup = require("nui.popup")

local ChatInput = Popup:extend("ChatInput")

function ChatInput:init(popup_options)
    local opts = {
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            padding = {
                left = 1,
                right = 1,
            },
            text = {
                top = " Prompt ",
                top_align = "center",
            },
        },
    }
    local options = vim.tbl_deep_extend("force", popup_options or {}, opts)

    ChatInput.super.init(self, options)
end

function ChatInput:clear()
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end

function ChatInput:lines()
    return vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
end

return ChatInput
