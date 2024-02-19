(local {: autoload} (require :nfnl.module))
(local {: get} (require :nfnl.core))

(local snapshot (autoload :neoai2.api.snapshot))
(local message (autoload :neoai2.api.message))
(local chat (autoload :neoai2.api.chat))
(local provider (autoload :neoai2.api.provider))
(local mappings (autoload :neoai2.mappings))

(local Layout (require :nui.layout))
(local event (. (require :nui.utils.autocmd) :event))

(local ChatInput (autoload :neoai2.ui.chat.input))
(local ChatOutput (autoload :neoai2.ui.chat.output))

(local Chat (Layout:extend :Chat))

(fn Chat.init [self s config layout-options]
  (set self.config config)
  (set self.snapshot s)

  (set self._mounted false)
  (set self._submitting false)

  (set self.input_popup (ChatInput))
  (set self.output_popup (ChatOutput s.provider s.model))

  (let [; TODO: Swap out layout_options with self.config
        options (vim.tbl_deep_extend :force
                  (or layout-options {})
                  {:relative :editor
                   :position {; TODO: Why does changing this do nothing?
                              :row 0
                              :col "100%"}
                   :size {:height "100%"
                          :width "30%"}})
        layout (Layout.Box [(Layout.Box self.output_popup {:size "80%"})
                            (Layout.Box self.input_popup {:size "20%"})]
                           {:dir :col})]
    ; TODO: Figure out how to allow the user to customise the layout
    (Chat.super.init self options layout)))

(fn Chat.rerender [self]
  (self.output_popup:render_snapshot self.snapshot)
  (self.input_popup:clear))

(fn Chat.set_snapshot [self snapshot]
  (set self.snapshot snapshot)
  (when (self:is_mounted)
    (self:rerender)))

(fn Chat.mount [self]
  (when (not self._mounted)
    (Chat.super.mount self)
    (set self._mounted true)
    (self:setup)))

(fn Chat.unmount [self]
  (when self._mounted
    (Chat.super.unmount self)
    (set self._mounted false)))

; TODO: Replace with property access?
;       So `chat.mounted` vs `chat:is_mounted()`
(fn Chat.is_mounted [self]
  self._mounted)

(fn Chat.toggle [self]
  (if (self:is_mounted)
    (self:unmount)
    (self:mount)))

(fn Chat.submit_input [self]
  (let [prompt (self.input_popup:lines)]
    (self.input_popup:clear)

    ; User prompt
    (let [user-message (message.user (table.concat prompt "\n"))]
      (snapshot.append_message self.snapshot user-message)
      (self.output_popup:append_message user-message))

    (self:submit)))
 
; TODO: Rename?
(fn Chat.submit [self]
  (when (not self._submitting)
    (set self._submitting true)

    ; TODO: Move to output_popup? Or at least a util module
    (self.output_popup:append_lines ["AI:" ""])

    (fn on-chunk [chunk]
      (when chunk
        (let [delta (provider.delta self.snapshot.provider chunk)]
          (when (next delta)
            (self.output_popup:append_string delta.content)))))

    (fn on-complete [err result]
      (if err
        (self.output_popup:append_lines [(.. "Error: " err)])
        (let [msg (provider.message self.snapshot.provider result)]
          (snapshot.append_message
            self.snapshot (message.assistant msg.content))))
      (self.output_popup:append_lines [""])
      (set self._submitting false))

    (chat.completions self.snapshot on-chunk on-complete)))

(fn Chat.setup_keybinds [self]
  (mappings.create_plug_maps false
    [{:desc "Select Up"
      :plug "<Plug>Neoai2Chat:SelectUp"
      :rhs #(vim.api.nvim_set_current_win self.output_popup.winid)}
     {:desc "Select Down"
      :plug "<Plug>Neoai2Chat:SelectDown"
      :rhs #(vim.api.nvim_set_current_win self.input_popup.winid)}
     {:desc :Submit
      :plug "<Plug>Neoai2Chat:SubmitPrompt"
      :rhs #(self:submit_input)}
     {:desc "Regenerate Last Prompt"
      :plug "<Plug>Neoai2Chat:RegenerateLastPrompt"
      :rhs (fn []
             (when (not self._submitting)
               (let [last-message
                     (get self.snapshot.messages (length self.snapshot.messages))]
                 (when (and last-message (= last-message.role :assistant))
                   (tset self.snapshot.messages
                         (length self.snapshot.messages) nil)
                   (self.output_popup:render_snapshot self.snapshot)
                   (self:submit)))))}])

  (when self.config.input.mappings
    (let [input-bufnr self.input_popup.bufnr]
      (each [mode user-mappings (pairs self.config.input.mappings)]
        (mappings.create_maps_to_plug input-bufnr mode user-mappings
                                      "Neoai2Chat:"))))

  (when self.config.output.mappings
    (let [output-bufnr self.output_popup.bufnr]
      (each [mode user-mappings (pairs self.config.output.mappings)]
        (mappings.create_maps_to_plug output-bufnr mode user-mappings
                                      "Neoai2Chat:")))))

(fn Chat.setup_events [self]
  (self.input_popup:on event.QuitPre #(self:unmount))
  (self.output_popup:on event.QuitPre #(self:unmount)))

(fn Chat.setup [self]
  (self:setup_keybinds)
  (self:setup_events)
  (self:rerender))

Chat
