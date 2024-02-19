-- [nfnl] Compiled from lua/neoai2/utils.fnl by https://github.com/Olical/nfnl, do not edit.
local function concat(a, ...)
  local out = {unpack(a)}
  for _, tbl in ipairs({...}) do
    for _0, v in ipairs(tbl) do
      table.insert(out, v)
    end
  end
  return out
end
local function clone(tbl)
  local ret = {}
  for k, v in pairs(tbl) do
    if (type(v) == "table") then
      ret[k] = clone(v)
    else
      ret[k] = v
    end
  end
  for k, v in ipairs(tbl) do
    if (type(v) == "table") then
      ret[k] = clone(v)
    else
      ret[k] = v
    end
  end
  return ret
end
local function split(input, delimiter)
  local result = {}
  local start = 1
  local split_start, split_end = nil
  while true do
    split_start, split_end = string.find(input, delimiter, start, true)
    if not split_start then
      table.insert(result, string.sub(input, start))
      break
    else
    end
    table.insert(result, string.sub(input, start, (split_start - 1)))
    start = (split_end + 1)
  end
  return result
end
local function lines(str)
  return split(str, "\n")
end
local function shell_error(str)
  return (0 ~= vim.v.shell_error)
end
local function buf_empty_3f(bufnr)
  local start_of_buf = vim.api.nvim_buf_get_lines(bufnr, 0, 2, false)
  return ((#start_of_buf == 1) and (start_of_buf[1] == ""))
end
local function selection()
  local mode = vim.fn.mode()
  if ((mode == "v") or (mode == "V")) then
    local saved_reg = vim.fn.getreg("v")
    local _ = vim.cmd("noautocmd sil norm \"vy")
    local selection0 = vim.fn.getreg("v")
    vim.fn.setreg("v", saved_reg)
    return selection0
  else
    return nil
  end
end
local json = {}
json.store = function(obj, path)
  local ok, file_contents = pcall(vim.json.encode, obj)
  if not ok then
    return false, ("Failed to encode json: " .. file_contents)
  else
    local ok0, err = pcall(vim.fn.writefile, {file_contents}, path)
    if not ok0 then
      return false, err
    else
      return true
    end
  end
end
json.load = function(path)
  local ok, file_contents = pcall(vim.fn.readfile, path)
  if not ok then
    return nil, file_contents
  else
    local ok0, obj = pcall(vim.json.decode, table.concat(file_contents, "\n"))
    if not ok0 then
      return nil, ("Failed to decode json: " .. obj)
    else
      return obj
    end
  end
end
return {concat = concat, clone = clone, split = split, lines = lines, shell_error = shell_error, is_buf_empty = buf_empty_3f, selection = selection, json = json}
