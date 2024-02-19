(local {: first} (require :nfnl.core))
(local Popup (require :nui.popup))
(local utils (require :neoai2.utils))

(local ChatOutput (Popup:extend :ChatOutput))

(fn ChatOutput.init [self provider model popup-options]
  (let [title :NeoAI2
        ;TODO: Change to supplying these indirectly through the Layout
        provider-part (.. "Provider: " provider)
        model-part (.. "(" model ")")
        bottom-text (.. provider-part " " model-part)

        opts {:enter false
              :focusable true
              :border {:style :rounded
                       :text {:top (.. " " title " ")
                              :top_align :center
                              :bottom (.. " " bottom-text " ")
                              :bottom_align :left}}}
        options (vim.tbl_deep_extend :force (or popup-options {}) opts)]
    (ChatOutput.super.init self options)))

(fn ChatOutput.clear [self]
  (vim.api.nvim_buf_set_lines self.bufnr 0 -1 false {}))

(fn ChatOutput.scroll_bottom [self]
  (let [output-line-count (vim.api.nvim_buf_line_count self.bufnr)]
    (vim.api.nvim_win_set_cursor self.winid [output-line-count 0])))

(fn ChatOutput.append_lines [self lines]
  (let [; If the buffer is empty, we want to start on the first line
        ; Otherwise, we want to start on the last line
        start-idx (if (utils.is_buf_empty self.bufnr) 0 -1)]
    (vim.api.nvim_buf_set_lines self.bufnr start-idx (- 1) false lines)
    (self:scroll_bottom)))

(fn ChatOutput.append_string [self str]
  (let [str (or str "")
        prev-line (first (vim.api.nvim_buf_get_lines self.bufnr -2 -1 false))
        ; The appended string could be finishing the previous line
        ; so we need to include the previous line in what we set in the buffer
        str (.. prev-line str)
        lines (vim.split str "\n" {:plain true})]
    (vim.api.nvim_buf_set_lines self.bufnr (- 2) (- 1) false lines)
    (self:scroll_bottom)))

(fn ChatOutput.append_message [self message]
  ; fennel-ls doesn't understand case statements
  (case message.role
    :user      (self:append_lines ["You:" ""])
    :assistant (self:append_lines ["AI:" ""])
    :system    (self:append_lines ["System:" ""]))
  (self:append_string (.. message.content "\n")))

(fn ChatOutput.render_snapshot [self snapshot]
  (self:clear)

  ; TODO: Set the title
  (each [_ message (ipairs snapshot.messages)]
    (self:append_message message)))

ChatOutput
