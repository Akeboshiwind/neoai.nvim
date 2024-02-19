-- [nfnl] Compiled from lua/neoai2/ui/chat/prompts.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = autoload("nfnl.core")
local update = _local_2_["update"]
local get = _local_2_["get"]
local pickers = autoload("telescope.pickers")
local finders = autoload("telescope.finders")
local previewers = autoload("telescope.previewers")
local previewer_utils = autoload("telescope.previewers.utils")
local config = autoload("telescope.config")
local actions = autoload("telescope.actions")
local action_state = autoload("telescope.actions.state")
local function select(opts)
  local opts0 = (opts or {})
  local _ = assert(opts0.prompts, "opts.prompts is required")
  local _0 = assert(opts0.select_action, "opts.select_action is required")
  local prompts = __fnl_global__process_2dprompts(opts0.prompts)
  local opts1
  local function _3_(_241)
    return (_241 or "prompts")
  end
  local function _4_(_241)
    return (_241 or __fnl_global__fill_2dprompt)
  end
  opts1 = update(update(opts0, "prompt_title", _3_), "select_action", _4_)
  local picker
  local function _5_(self, entry, status)
    local prompt_fn = get(prompts, entry.value)
    local prompt, _1 = prompt_fn(entry.value)
    local function _6_()
      return vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, prompt)
    end
    return previewer_utils.with_preview_window(status, nil, _6_)
  end
  local function _7_(prompt_bufnr, _1)
    local function _8_()
      actions.close(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      local prompt_fn = get(prompts, selection.value)
      local prompt, pos = prompt_fn(selection.value)
      return opts1.select_action(prompt, pos)
    end
    do end (actions.select_default):replace(_8_)
    return true
  end
  picker = pickers.new(opts1, {prompt_title = opts1.prompt_title, finder = finders.new_table(keys(prompts)), sorter = config.values.generic_sorter(opts1), previewer = previewers.new_buffer_previewer({define_preview = _5_}), attach_mappings = _7_})
  return picker:find()
end
return {select = select}
