-- [nfnl] Compiled from lua/neoai2/api/snapshot.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = autoload("nfnl.core")
local assoc = _local_2_["assoc"]
local get_in = _local_2_["get-in"]
local provider = autoload("neoai2.api.provider")
local utils = autoload("neoai2.utils")
local function set_model(snapshot, user_provider, model, params)
  local provider_config = provider.config(user_provider)
  local model_config = get_in(provider_config, {"models", model})
  return assoc(assoc(assoc(assoc(snapshot, "provider", user_provider), "provider_config", provider_config), "model", model), "params", (params or model_config.default_params or {}))
end
local function new(provider0, model, params)
  return set_model({messages = {}}, provider0, model, params)
end
local function save(snapshot, path)
  local obj = {messages = snapshot.messages, model = snapshot.model, params = snapshot.params, provider = snapshot.provider}
  local ok, err = utils.json.store(obj, path)
  if not ok then
    return nil, err
  else
    return true
  end
end
local function load(path)
  local snapshot, err = utils.json.load(path)
  if not snapshot then
    return nil, err
  else
    return set_model(snapshot, snapshot.provider, snapshot.model, snapshot.params)
  end
end
local function append_message(snapshot, message)
  table.insert(snapshot.messages, message)
  return snapshot
end
return {new = new, save = save, load = load, set_model = set_model, append_message = append_message}
