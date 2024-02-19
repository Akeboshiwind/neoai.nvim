; NOTE: I don't think this namespace if finished, it uses a bunch of undefined functions

(local {: autoload} (require :nfnl.module))
(local {: update : get} (autoload :nfnl.core))

(local pickers (autoload :telescope.pickers))
(local finders (autoload :telescope.finders))
(local previewers (autoload :telescope.previewers))
(local previewer-utils (autoload :telescope.previewers.utils))
(local config (autoload :telescope.config))
(local actions (autoload :telescope.actions))
(local action-state (autoload :telescope.actions.state))

; TODO: Also support vim.ui.select

; Will this error as it shadows a fnl function?
(fn select [opts]
  "Opens a telescope prompt picker with the given prompts."
  (let [opts (or opts {})
        _ (assert opts.prompts "opts.prompts is required")
        _ (assert opts.select_action "opts.select_action is required")

        prompts (process-prompts opts.prompts)

        opts (-> opts
                 (update :prompt_title #(or $ "prompts"))
                 (update :select_action #(or $ fill-prompt)))

        picker
        (pickers.new opts
          {:prompt_title opts.prompt_title
           :finder (finders.new_table (keys prompts))
           :sorter (config.values.generic_sorter opts)
           :previewer
           (previewers.new_buffer_previewer
             {:define_preview
              (fn [self entry status]
                (let [prompt-fn (get prompts entry.value)
                      (prompt _) (prompt-fn entry.value)]
                  (previewer-utils.with_preview_window status nil
                    #(vim.api.nvim_buf_set_lines self.state.bufnr 0 -1 false prompt))))})
           :attach_mappings
           (fn [prompt-bufnr _]
             (actions.select_default:replace
               #(do (actions.close prompt-bufnr)
                    (let [selection (action-state.get_selected_entry)
                          prompt-fn (get prompts selection.value)
                          (prompt pos) (prompt-fn selection.value)]
                      (opts.select_action prompt pos))))
             true)})]
    (picker:find)))

{: select}
