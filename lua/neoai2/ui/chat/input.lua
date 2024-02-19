-- [nfnl] Compiled from lua/neoai2/ui/chat/input.fnl by https://github.com/Olical/nfnl, do not edit.
local Popup = require("nui.popup")
local ChatInput = Popup:extend("ChatInput")
ChatInput.init = function(self, popup_options)
  local opts = {border = {padding = {left = 1, right = 1}, style = "rounded", text = {top = " Prompt ", top_align = "center"}}, enter = true, focusable = true}
  local options = vim.tbl_deep_extend("force", (popup_options or {}), opts)
  return ChatInput.super.init(self, options)
end
ChatInput.clear = function(self)
  return vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end
ChatInput.lines = function(self)
  return vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
end
return ChatInput
