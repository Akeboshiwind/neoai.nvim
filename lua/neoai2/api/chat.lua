-- [nfnl] Compiled from lua/neoai2/api/chat.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local provider = autoload("neoai2.api.provider")
local logger = autoload("neoai2.logger")
local function sync_completions(snapshot)
  local method = provider.method(snapshot.provider, {"chat", "sync_completions"})
  if method then
    return method(snapshot)
  else
    local msg = "Provider does not support sync completions"
    logger.error(msg)
    return error(msg)
  end
end
local function completions(snapshot, on_chunk, on_complete)
  local method = provider.method(snapshot.provider, {"chat", "completions"})
  if method then
    return method(snapshot, on_chunk, on_complete)
  else
    local msg = "Provider does not support async completions"
    logger.error(msg)
    return error(msg)
  end
end
return {sync_completions = sync_completions, completions = completions}
