-- [nfnl] Compiled from lua/neoai2/ui/chat/output.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.core")
local first = _local_1_["first"]
local Popup = require("nui.popup")
local utils = require("neoai2.utils")
local ChatOutput = Popup:extend("ChatOutput")
ChatOutput.init = function(self, provider, model, popup_options)
  local title = "NeoAI2"
  local provider_part = ("Provider: " .. provider)
  local model_part = ("(" .. model .. ")")
  local bottom_text = (provider_part .. " " .. model_part)
  local opts = {focusable = true, border = {style = "rounded", text = {top = (" " .. title .. " "), top_align = "center", bottom = (" " .. bottom_text .. " "), bottom_align = "left"}}, enter = false}
  local options = vim.tbl_deep_extend("force", (popup_options or {}), opts)
  return ChatOutput.super.init(self, options)
end
ChatOutput.clear = function(self)
  return vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})
end
ChatOutput.scroll_bottom = function(self)
  local output_line_count = vim.api.nvim_buf_line_count(self.bufnr)
  return vim.api.nvim_win_set_cursor(self.winid, {output_line_count, 0})
end
ChatOutput.append_lines = function(self, lines)
  local start_idx
  if utils.is_buf_empty(self.bufnr) then
    start_idx = 0
  else
    start_idx = -1
  end
  vim.api.nvim_buf_set_lines(self.bufnr, start_idx, ( - 1), false, lines)
  return self:scroll_bottom()
end
ChatOutput.append_string = function(self, str)
  local str0 = (str or "")
  local prev_line = first(vim.api.nvim_buf_get_lines(self.bufnr, -2, -1, false))
  local str1 = (prev_line .. str0)
  local lines = vim.split(str1, "\n", {plain = true})
  vim.api.nvim_buf_set_lines(self.bufnr, ( - 2), ( - 1), false, lines)
  return self:scroll_bottom()
end
ChatOutput.append_message = function(self, message)
  do
    local _3_ = message.role
    if (_3_ == "user") then
      self:append_lines({"You:", ""})
    elseif (_3_ == "assistant") then
      self:append_lines({"AI:", ""})
    elseif (_3_ == "system") then
      self:append_lines({"System:", ""})
    else
    end
  end
  return self:append_string((message.content .. "\n"))
end
ChatOutput.render_snapshot = function(self, snapshot)
  self:clear()
  for _, message in ipairs(snapshot.messages) do
    self:append_message(message)
  end
  return nil
end
return ChatOutput
