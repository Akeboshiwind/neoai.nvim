-- [nfnl] Compiled from lua/neoai2/ui/chat/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = autoload("nfnl.core")
local get = _local_2_["get"]
local get_in = _local_2_["get-in"]
local snapshot = autoload("neoai2.api.snapshot")
local message = autoload("neoai2.api.message")
local mappings = autoload("neoai2.mappings")
local utils = autoload("neoai2.utils")
local Chat = require("neoai2.ui.chat.chat")
local function default_snapshot(config)
  local model = config["default-model"]
  return snapshot.new(model.provider, model.model, model.params)
end
local function append_context(s)
  local context = utils.selection()
  if context then
    return snapshot.append_message(s, message.system(("Given the following as context:\n" .. context)))
  else
    return nil
  end
end
local function setup(config)
  local chat_cfg = config.chat
  local chat = Chat(default_snapshot(chat_cfg), chat_cfg)
  local function _4_()
    append_context(chat.snapshot)
    return chat:toggle()
  end
  local function _5_()
    local provider = "openai"
    local models = get_in(config, {"providers", provider, "models"})
    local model_names = vim.tbl_keys(models)
    local function _6_(model)
      local params = get(models, model)
      local s = chat.snapshot
      snapshot.set_model(s, provider, model, params)
      append_context(s)
      chat:set_snapshot(s)
      return chat:mount()
    end
    return vim.ui.select(model_names, {prompt = "Select a model:"}, _6_)
  end
  local function _7_()
    local s = default_snapshot(chat_cfg)
    append_context(s)
    chat:set_snapshot(s)
    return chat:mount()
  end
  local function _8_()
    local provider = "openai"
    local models = get_in(config, {"providers", provider, "models"})
    local model_names = vim.tbl_keys(models)
    local function _9_(model)
      local params = get(models, model)
      local s = snapshot.new(provider, model, params)
      append_context(s)
      chat:set_snapshot(s)
      return chat:mount()
    end
    return vim.ui.select(model_names, {prompt = "Select a model:"}, _9_)
  end
  mappings.create_plug_maps(false, {{desc = "Toggle Chat window", plug = "<Plug>Neoai2Chat:ToggleChat", rhs = _4_}, {desc = "New Chat Window", plug = "<Plug>Neoai2Chat:ToggleChatSelectModel", rhs = _5_}, {desc = "New Chat Window", plug = "<Plug>Neoai2Chat:NewChat", rhs = _7_}, {desc = "New Chat Window", plug = "<Plug>Neoai2Chat:NewChatSelectModel", rhs = _8_}})
  if chat_cfg.mappings then
    for mode, user_mappings in pairs(chat_cfg.mappings) do
      mappings.create_maps_to_plug(false, mode, user_mappings, "Neoai2Chat:")
    end
    return nil
  else
    return nil
  end
end
return {setup = setup}
