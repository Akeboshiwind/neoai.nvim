-- [nfnl] Compiled from lua/neoai2/mappings.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.core")
local first = _local_1_["first"]
local table_3f = _local_1_["table?"]
local string_3f = _local_1_["string?"]
local function create_plug_maps(bufnr, plug_bindings)
  for _, binding in ipairs(plug_bindings) do
    vim.keymap.set("", binding.plug, binding.rhs, {buffer = bufnr, desc = binding.desc, nowait = true})
  end
  return nil
end
local function create_maps_to_plug(bufnr, mode, bindings, prefix)
  for lhs, rhs in pairs(bindings) do
    if rhs then
      local opts
      do
        local tbl_14_auto = {buffer = bufnr, nowait = true, remap = true}
        local function _2_()
          if table_3f(rhs) then
            return rhs
          else
            return {}
          end
        end
        for k, v in pairs(_2_()) do
          local k_15_auto, v_16_auto = nil, nil
          if (type(k) == "string") then
            k_15_auto, v_16_auto = k, v
          else
            k_15_auto, v_16_auto = nil
          end
          if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then
            tbl_14_auto[k_15_auto] = v_16_auto
          else
          end
        end
        opts = tbl_14_auto
      end
      local rhs0
      if (table_3f(rhs) and first(rhs)) then
        rhs0 = first(rhs)
      else
        rhs0 = rhs
      end
      local rhs1
      if string_3f(rhs0) then
        if not rhs0:match("[<:]") then
          rhs1 = ("<Plug>" .. prefix .. rhs0 .. "<CR>")
        else
          rhs1 = (rhs0 .. "<CR>")
        end
      else
        rhs1 = rhs0
      end
      local rhs2
      if (string_3f(rhs1) and (mode == "i")) then
        rhs2 = ("<C-o>" .. rhs1)
      else
        rhs2 = rhs1
      end
      vim.keymap.set(mode, lhs, rhs2, opts)
    else
    end
  end
  return nil
end
return {create_plug_maps = create_plug_maps, create_maps_to_plug = create_maps_to_plug}
