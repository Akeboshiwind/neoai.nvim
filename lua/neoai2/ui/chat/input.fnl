(local Popup (require :nui.popup))

(local ChatInput (Popup:extend :ChatInput))

(fn ChatInput.init [self popup-options]
  (let [opts {:border {:padding {:left 1 :right 1}
                       :style :rounded
                       :text {:top " Prompt " :top_align :center}}
              :enter true
              :focusable true}
        options (vim.tbl_deep_extend :force (or popup-options {}) opts)]
    (ChatInput.super.init self options)))

(fn ChatInput.clear [self]
  (vim.api.nvim_buf_set_lines self.bufnr 0 -1 false {}))

(fn ChatInput.lines [self]
  (vim.api.nvim_buf_get_lines self.bufnr 0 -1 false))

ChatInput
