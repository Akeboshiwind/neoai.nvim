-- [nfnl] Compiled from lua/neoai2/ui/chat/chat.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = require("nfnl.core")
local get = _local_2_["get"]
local snapshot = autoload("neoai2.api.snapshot")
local message = autoload("neoai2.api.message")
local chat = autoload("neoai2.api.chat")
local provider = autoload("neoai2.api.provider")
local mappings = autoload("neoai2.mappings")
local Layout = require("nui.layout")
local event = (require("nui.utils.autocmd")).event
local ChatInput = autoload("neoai2.ui.chat.input")
local ChatOutput = autoload("neoai2.ui.chat.output")
local Chat = Layout:extend("Chat")
Chat.init = function(self, s, config, layout_options)
  self.config = config
  self.snapshot = s
  self._mounted = false
  self._submitting = false
  self.input_popup = ChatInput()
  self.output_popup = ChatOutput(s.provider, s.model)
  local options = vim.tbl_deep_extend("force", (layout_options or {}), {relative = "editor", position = {row = 0, col = "100%"}, size = {height = "100%", width = "30%"}})
  local layout = Layout.Box({Layout.Box(self.output_popup, {size = "80%"}), Layout.Box(self.input_popup, {size = "20%"})}, {dir = "col"})
  return Chat.super.init(self, options, layout)
end
Chat.rerender = function(self)
  do end (self.output_popup):render_snapshot(self.snapshot)
  return (self.input_popup):clear()
end
Chat.set_snapshot = function(self, snapshot0)
  self.snapshot = snapshot0
  if self:is_mounted() then
    return self:rerender()
  else
    return nil
  end
end
Chat.mount = function(self)
  if not self._mounted then
    Chat.super.mount(self)
    self._mounted = true
    return self:setup()
  else
    return nil
  end
end
Chat.unmount = function(self)
  if self._mounted then
    Chat.super.unmount(self)
    self._mounted = false
    return nil
  else
    return nil
  end
end
Chat.is_mounted = function(self)
  return self._mounted
end
Chat.toggle = function(self)
  if self:is_mounted() then
    return self:unmount()
  else
    return self:mount()
  end
end
Chat.submit_input = function(self)
  local prompt = (self.input_popup):lines()
  do end (self.input_popup):clear()
  do
    local user_message = message.user(table.concat(prompt, "\n"))
    snapshot.append_message(self.snapshot, user_message)
    do end (self.output_popup):append_message(user_message)
  end
  return self:submit()
end
Chat.submit = function(self)
  if not self._submitting then
    self._submitting = true
    do end (self.output_popup):append_lines({"AI:", ""})
    local function on_chunk(chunk)
      if chunk then
        local delta = provider.delta(self.snapshot.provider, chunk)
        if next(delta) then
          return (self.output_popup):append_string(delta.content)
        else
          return nil
        end
      else
        return nil
      end
    end
    local function on_complete(err, result)
      if err then
        do end (self.output_popup):append_lines({("Error: " .. err)})
      else
        local msg = provider.message(self.snapshot.provider, result)
        snapshot.append_message(self.snapshot, message.assistant(msg.content))
      end
      do end (self.output_popup):append_lines({""})
      self._submitting = false
      return nil
    end
    return chat.completions(self.snapshot, on_chunk, on_complete)
  else
    return nil
  end
end
Chat.setup_keybinds = function(self)
  local function _11_()
    return vim.api.nvim_set_current_win(self.output_popup.winid)
  end
  local function _12_()
    return vim.api.nvim_set_current_win(self.input_popup.winid)
  end
  local function _13_()
    return self:submit_input()
  end
  local function _14_()
    if not self._submitting then
      local last_message = get(self.snapshot.messages, #self.snapshot.messages)
      if (last_message and (last_message.role == "assistant")) then
        self.snapshot.messages[#self.snapshot.messages] = nil
        do end (self.output_popup):render_snapshot(self.snapshot)
        return self:submit()
      else
        return nil
      end
    else
      return nil
    end
  end
  mappings.create_plug_maps(false, {{desc = "Select Up", plug = "<Plug>Neoai2Chat:SelectUp", rhs = _11_}, {desc = "Select Down", plug = "<Plug>Neoai2Chat:SelectDown", rhs = _12_}, {desc = "Submit", plug = "<Plug>Neoai2Chat:SubmitPrompt", rhs = _13_}, {desc = "Regenerate Last Prompt", plug = "<Plug>Neoai2Chat:RegenerateLastPrompt", rhs = _14_}})
  if self.config.input.mappings then
    local input_bufnr = self.input_popup.bufnr
    for mode, user_mappings in pairs(self.config.input.mappings) do
      mappings.create_maps_to_plug(input_bufnr, mode, user_mappings, "Neoai2Chat:")
    end
  else
  end
  if self.config.output.mappings then
    local output_bufnr = self.output_popup.bufnr
    for mode, user_mappings in pairs(self.config.output.mappings) do
      mappings.create_maps_to_plug(output_bufnr, mode, user_mappings, "Neoai2Chat:")
    end
    return nil
  else
    return nil
  end
end
Chat.setup_events = function(self)
  local function _19_()
    return self:unmount()
  end
  do end (self.input_popup):on(event.QuitPre, _19_)
  local function _20_()
    return self:unmount()
  end
  return (self.output_popup):on(event.QuitPre, _20_)
end
Chat.setup = function(self)
  self:setup_keybinds()
  self:setup_events()
  return self:rerender()
end
return Chat
