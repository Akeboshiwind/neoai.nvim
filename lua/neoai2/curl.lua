-- [nfnl] Compiled from lua/neoai2/curl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local utils = autoload("neoai2.utils")
local function stream(url, extra_args, on_stdout_chunk, on_complete)
  local stdout = vim.loop.new_pipe()
  local stderr = vim.loop.new_pipe()
  local stderr_chunks = {}
  local on_stderr_read
  local function _2_(err, chunk)
    assert(not err, err)
    if chunk then
      return table.insert(stderr_chunks, chunk)
    else
      return nil
    end
  end
  on_stderr_read = _2_
  local cmd = "curl"
  local args = utils.concat({"--silent", "--show-error", "--no-buffer", url}, extra_args)
  local handle, err_code = nil, nil
  local function _4_(code)
    stdout:close()
    stderr:close()
    handle:close()
    local function _5_()
      if (0 ~= code) then
        return on_complete({code = code, msg = vim.trim(table.concat(stderr_chunks, ""))})
      else
        return on_complete()
      end
    end
    return vim.schedule(_5_)
  end
  handle, err_code = vim.loop.spawn(cmd, {args = args, stdio = {nil, stdout, stderr}}, _4_)
  if not handle then
    on_complete({code = err_code, msg = "Could not be started"})
  else
    local function _7_(err, chunk)
      assert(not err, err)
      if chunk then
        local function _8_()
          return on_stdout_chunk(chunk)
        end
        return vim.schedule(_8_)
      else
        return nil
      end
    end
    stdout:read_start(_7_)
    stderr:read_start(on_stderr_read)
  end
  return handle
end
local function parse_events(input)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for _, event in ipairs(utils.split(input, "\n\n")) do
    local val_19_auto
    if ("" ~= event) then
      local data
      do
        local tbl_17_auto0 = {}
        local i_18_auto0 = #tbl_17_auto0
        for field in event:gmatch("[^\n]+") do
          local val_19_auto0
          if field:match("^data:") then
            val_19_auto0 = vim.trim(field:gsub("data:", ""))
          else
            val_19_auto0 = nil
          end
          if (nil ~= val_19_auto0) then
            i_18_auto0 = (i_18_auto0 + 1)
            do end (tbl_17_auto0)[i_18_auto0] = val_19_auto0
          else
          end
        end
        data = tbl_17_auto0
      end
      local data0 = table.concat(data, "\n")
      val_19_auto = {data = data0}
    else
      val_19_auto = nil
    end
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local function stream_ss_events(url, extra_args, on_event, on_complete)
  local function _15_(chunk)
    if chunk then
      for _, event in ipairs(parse_events(chunk)) do
        on_event(event)
      end
      return nil
    else
      return nil
    end
  end
  return stream(url, extra_args, _15_, on_complete)
end
return {stream = stream, stream_ss_events = stream_ss_events}
