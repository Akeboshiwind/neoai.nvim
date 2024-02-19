-- [nfnl] Compiled from lua/neoai2/api/provider/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = require("nfnl.core")
local get_in = _local_2_["get-in"]
local get = _local_2_["get"]
local logger = autoload("neoai2.logger")
local function method(provider, method0)
  local mod = require(("neoai2.api.provider." .. provider))
  return get_in(mod, method0)
end
local function delta(provider, chunk)
  local mthd = method(provider, {"utils", "delta"})
  if mthd then
    return mthd(chunk)
  else
    local msg = "Provider does not support getting a delta"
    logger.error(msg)
    return error(msg)
  end
end
local function message(provider, chunk)
  local mthd = method(provider, {"utils", "message"})
  if mthd then
    return mthd(chunk)
  else
    local msg = "Provider does not support getting the message"
    logger.error(msg)
    return error(msg)
  end
end
local provider_configs = {}
local function setup(config)
  provider_configs = config.providers
  return nil
end
local function config(provider)
  return get(provider_configs, provider)
end
return {method = method, delta = delta, message = message, setup = setup, config = config}
