; TODO: Move to ui namespace?
(local {: autoload} (require :nfnl.module))
(local {: empty?} (autoload :nfnl.core))
(local logger (autoload :neoai2.logger))
(local config (autoload :neoai2.config))
(local snapshot (autoload :neoai2.api.snapshot))
(local message (autoload :neoai2.api.message))
(local chat (autoload :neoai2.api.chat))
(local provider (autoload :neoai2.api.provider))
(local utils (autoload :neoai2.utils))
(local mappings (autoload :neoai2.mappings))

(fn inject [inject-cfg prompt]
  (let [model inject-cfg.default-model
        s (-> (snapshot.new model.provider model.model model.params)
              (snapshot.append_message (message.user prompt)))

        on-receive-chunk
        (do (var has-made-change false)
            (fn [chunk]
              (when chunk
                (let [delta (provider.delta s.provider chunk)]
                  ; OpenAI returns a blank delta field in the last
                  ; message, this ignores that
                  (when (next delta)
                    ; Allow changes to be undone all at once
                    (when has-made-change
                      (vim.cmd "undojoin"))
                    (set has-made-change true)

                    ; delta.content is a string with `\n` characters
                    ; nvim_put expects a list of lines
                    (let [content (utils.lines delta.content)]
                      (vim.api.nvim_put content :c true true)))))))

        on-complete
        (fn [_err _response]
          ; Unbind cancel mapping
          ; NOTE: This will also run when we `cancel` later
          (mappings.create_plug_maps false
            [{:desc :Cancel
              :plug "<Plug>Neoai2Inject:Cancel"
              :rhs (fn [])}]))

        ; NOTE: Handle is the return value of `vim.loop.spawn`
        handle (chat.completions s on-receive-chunk on-complete)]

    ; Allow the user to cancel the injection
    (mappings.create_plug_maps false
      [{:desc :Cancel
        :plug "<Plug>Neoai2Inject:Cancel"
        :rhs #(do (vim.loop.process_kill handle)
                  (logger.info "Cancelled injection"))}])))

(fn setup [config]
  (let [inject-cfg config.inject]
    (when inject-cfg.enabled
      (let [plug-maps [{:desc "Inject text"
                        :plug "<Plug>Neoai2Inject:Inject"
                        :rhs #(inject inject-cfg (vim.fn.input "Neoai2> "))}
                       {:desc "Cancel Injection"
                        :plug "<Plug>Neoai2Inject:Cancel"
                        :rhs (fn [])}]]
        (mappings.create_plug_maps false plug-maps))
      (mappings.create_maps_to_plug false :n inject-cfg.mappings "Neoai2Inject:")

      ; User Commands
      (vim.api.nvim_create_user_command :Neoai2Inject
        (fn [opts]
          (inject inject-cfg
                  (if (empty? opts.args)
                    (vim.fn.input "Neoai2> ")
                    opts.args)))
        {:nargs "*"}))))

{: inject
 : setup}
