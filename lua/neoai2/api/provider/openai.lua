-- [nfnl] Compiled from lua/neoai2/api/provider/openai.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = autoload("nfnl.core")
local get_in = _local_2_["get-in"]
local first = _local_2_["first"]
local logger = autoload("neoai2.logger")
local curl = autoload("neoai2.curl")
local u = autoload("neoai2.utils")
local utils = {}
utils.delta = function(chunk)
  return get_in(chunk, {"choices", 1, "delta"})
end
utils.message = function(response)
  return get_in(response, {"choices", 1, "message"})
end
local chat = {}
local base_url = "https://api.openai.com/v1"
local chat_completions_url = (base_url .. "/chat/completions")
chat.sync_completions = function(snapshot)
  local api_key = snapshot.provider_config["api-key"]
  local data = vim.tbl_deep_extend("force", {messages = snapshot.messages, model = snapshot.model}, snapshot.params)
  local output = vim.fn.system({"curl", "--silent", "--show-error", "--no-buffer", chat_completions_url, "-H", "Content-Type: application/json", "-H", ("Authorization: Bearer " .. api_key), "-d", vim.json.encode(data)})
  if u.shell_error() then
    return nil, "Failed to run curl"
  else
    local ok, json = pcall(vim.json.decode, output)
    if not ok then
      return nil, "Failed to decode JSON"
    else
      return json
    end
  end
end
local function merge_chunks(chunks)
  if (first(chunks) == nil) then
    return {}
  else
    local result = first(chunks)
    local function _5_()
      local out_choice = {message = {}}
      for _, chunk in ipairs(chunks) do
        local choice = first(chunk.choices)
        local delta = choice.delta
        out_choice.index = choice.index
        out_choice.finish_reason = choice.finish_reason
        if (delta.role ~= nil) then
          out_choice.message.role = delta.role
        else
        end
        if (delta.content ~= nil) then
          out_choice.message.content = ((out_choice.message.content or "") .. delta.content)
        else
        end
        out_choice = out_choice
      end
      return out_choice
    end
    result.choices = {_5_()}
    return result
  end
end
chat.completions = function(snapshot, on_chunk, on_complete)
  local api_key = snapshot.provider_config["api-key"]
  local params = snapshot.params
  local data = vim.tbl_deep_extend("force", {messages = snapshot.messages, model = snapshot.model, stream = true}, params)
  local args = {"-H", "Content-Type: application/json", "-H", ("Authorization: Bearer " .. api_key), "-d", vim.json.encode(data)}
  local chunks = {}
  local function on_event(event)
    local data0 = event.data
    if not string.find(data0, "%[DONE%]") then
      local ok, json = pcall(vim.json.decode, data0)
      if (not ok or (json.error ~= nil)) then
        return logger.warning(("Failed to decode JSON: " .. data0))
      else
        table.insert(chunks, json)
        return on_chunk(json)
      end
    else
      return nil
    end
  end
  local function wrap_on_complete(err)
    if (err ~= nil) then
      return on_complete(err)
    else
      return on_complete(nil, merge_chunks(chunks))
    end
  end
  return curl.stream_ss_events(chat_completions_url, args, on_event, wrap_on_complete)
end
return {utils = utils, chat = chat}
