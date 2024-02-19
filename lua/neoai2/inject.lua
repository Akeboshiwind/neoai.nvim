-- [nfnl] Compiled from lua/neoai2/inject.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = autoload("nfnl.core")
local empty_3f = _local_2_["empty?"]
local logger = autoload("neoai2.logger")
local config = autoload("neoai2.config")
local snapshot = autoload("neoai2.api.snapshot")
local message = autoload("neoai2.api.message")
local chat = autoload("neoai2.api.chat")
local provider = autoload("neoai2.api.provider")
local utils = autoload("neoai2.utils")
local mappings = autoload("neoai2.mappings")
local function inject(inject_cfg, prompt)
  local model = inject_cfg["default-model"]
  local s = snapshot.append_message(snapshot.new(model.provider, model.model, model.params), message.user(prompt))
  local on_receive_chunk
  do
    local has_made_change = false
    local function _3_(chunk)
      if chunk then
        local delta = provider.delta(s.provider, chunk)
        if next(delta) then
          if has_made_change then
            vim.cmd("undojoin")
          else
          end
          has_made_change = true
          local content = utils.lines(delta.content)
          return vim.api.nvim_put(content, "c", true, true)
        else
          return nil
        end
      else
        return nil
      end
    end
    on_receive_chunk = _3_
  end
  local on_complete
  local function _7_(_err, _response)
    local function _8_()
    end
    return mappings.create_plug_maps(false, {{desc = "Cancel", plug = "<Plug>Neoai2Inject:Cancel", rhs = _8_}})
  end
  on_complete = _7_
  local handle = chat.completions(s, on_receive_chunk, on_complete)
  local function _9_()
    vim.loop.process_kill(handle)
    return logger.info("Cancelled injection")
  end
  return mappings.create_plug_maps(false, {{desc = "Cancel", plug = "<Plug>Neoai2Inject:Cancel", rhs = _9_}})
end
local function setup(config0)
  local inject_cfg = config0.inject
  if inject_cfg.enabled then
    do
      local plug_maps
      local function _10_()
        return inject(inject_cfg, vim.fn.input("Neoai2> "))
      end
      local function _11_()
      end
      plug_maps = {{desc = "Inject text", plug = "<Plug>Neoai2Inject:Inject", rhs = _10_}, {desc = "Cancel Injection", plug = "<Plug>Neoai2Inject:Cancel", rhs = _11_}}
      mappings.create_plug_maps(false, plug_maps)
    end
    mappings.create_maps_to_plug(false, "n", inject_cfg.mappings, "Neoai2Inject:")
    local function _12_(opts)
      local function _13_()
        if empty_3f(opts.args) then
          return vim.fn.input("Neoai2> ")
        else
          return opts.args
        end
      end
      return inject(inject_cfg, _13_())
    end
    return vim.api.nvim_create_user_command("Neoai2Inject", _12_, {nargs = "*"})
  else
    return nil
  end
end
return {inject = inject, setup = setup}
