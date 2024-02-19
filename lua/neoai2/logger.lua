-- [nfnl] Compiled from lua/neoai2/logger.fnl by https://github.com/Olical/nfnl, do not edit.
local function debug(message)
  return vim.notify(message, vim.log.levels.DEBUG, {title = "NeoAI"})
end
local function info(message)
  return vim.notify(message, vim.log.levels.INFO, {title = "NeoAI"})
end
local function warning(message)
  return vim.notify(message, vim.log.levels.WARN, {title = "NeoAI"})
end
local function error(message)
  return vim.notify(message, vim.log.levels.ERROR, {title = "NeoAI"})
end
local function deprecation(what, instead)
  return warning((what .. " is deprecated, use " .. instead))
end
return {deprecation = deprecation, debug = debug, info = info, warning = warning, error = error}
