-- [nfnl] Compiled from lua/neoai2/api/message.fnl by https://github.com/Olical/nfnl, do not edit.
local function message(role, content)
  return {content = content, role = role}
end
local function system(content)
  return message("system", content)
end
local function user(content)
  return message("user", content)
end
local function assistant(content)
  return message("assistant", content)
end
return {system = system, user = user, assistant = assistant}
