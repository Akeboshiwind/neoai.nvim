local M = {}

-- TODO: Also support vim.ui.select
--- Opens a telescope prompt picker with the given prompts.
--
-- @param opts.prompts The prompts to display in the picker.
-- @param opts.prompt_title The title of the prompt picker.
-- @param opts.select_action A function that's called when enter is pressed on an entry
function M.select(opts)
    -- Config
    local opts = opts or {}

    assert(opts.prompts, "opts.prompts is required")
    assert(opts.select_action, "opts.select_action is required")

    local prompts = process_prompts(opts.prompts)
    opts.prompt_title = opts.prompt_title or "prompts"
    opts.select_action = opts.select_action or M.fill_prompt

    -- Dependencies
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local previewers = require("telescope.previewers")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers
        .new(opts, {
            prompt_title = opts.prompt_title,
            finder = finders.new_table(keys(prompts)),
            sorter = conf.generic_sorter(opts),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry, status)
                    local prompt, _ = prompts[entry.value](entry.value)
                    return require("telescope.previewers.utils").with_preview_window(status, nil, function()
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, prompt)
                    end)
                end,
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    local prompt, pos = prompts[selection.value](selection.value)

                    opts.select_action(prompt, pos)
                end)
                return true
            end,
        })
        :find()
end

return
