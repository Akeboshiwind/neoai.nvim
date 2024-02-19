-- [nfnl] Compiled from lua/neoai2.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local config = autoload("neoai2.config")
local api_provider = autoload("neoai2.api.provider")
local inject = autoload("neoai2.inject")
local chat = autoload("neoai2.ui.chat")
local function setup(opts)
  local opts0 = (opts or {})
  local cfg = config.setup(opts0)
  api_provider.setup(cfg)
  inject.setup(cfg)
  chat.setup(cfg)
  return cfg
end
return {setup = setup}
