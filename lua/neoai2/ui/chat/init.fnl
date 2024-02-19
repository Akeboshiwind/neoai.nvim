(local {: autoload} (require :nfnl.module))
(local {: get : get-in} (autoload :nfnl.core))
(local snapshot (autoload :neoai2.api.snapshot))
(local message (autoload :neoai2.api.message))
(local mappings (autoload :neoai2.mappings))
(local utils (autoload :neoai2.utils))

(local Chat (require :neoai2.ui.chat.chat))

(fn default-snapshot [config]
  (let [model config.default-model]
    (snapshot.new model.provider model.model model.params)))

(fn append-context [s]
  (let [context (utils.selection)]
    (when context
      (snapshot.append_message s
        (message.system (.. "Given the following as context:\n" context))))))

(fn setup [config]
  (let [chat-cfg config.chat
        chat (Chat (default-snapshot chat-cfg) chat-cfg)]
    (mappings.create_plug_maps false
      [{:desc "Toggle Chat window"
        :plug "<Plug>Neoai2Chat:ToggleChat"
        :rhs (fn []
               (append-context chat.snapshot)
               (chat:toggle))}
       {:desc "New Chat Window"
        :plug "<Plug>Neoai2Chat:ToggleChatSelectModel"
        :rhs (fn []
               (let [; TODO: Don't hardcode
                     provider :openai
                     models (get-in config [:providers provider :models])
                     model-names (vim.tbl_keys models)]
                 (vim.ui.select
                   model-names
                   {:prompt "Select a model:"}
                   (fn [model]
                     (let [params (get models model)
                           s chat.snapshot]
                       (snapshot.set_model
                         s provider model params)
                       (append-context s)
                       (chat:set_snapshot s)
                       (chat:mount))))))}
       {:desc "New Chat Window"
        :plug "<Plug>Neoai2Chat:NewChat"
        :rhs (fn []
               (let [s (default-snapshot chat-cfg)]
                 (append-context s)
                 (chat:set_snapshot s)
                 (chat:mount)))}
       {:desc "New Chat Window"
        :plug "<Plug>Neoai2Chat:NewChatSelectModel"
        :rhs (fn []
               (let [; TODO: Don't hardcode provider
                     provider :openai
                     models (get-in config [:providers provider :models])
                     model-names (vim.tbl_keys models)]
                 (vim.ui.select
                   model-names
                   {:prompt "Select a model:"}
                   (fn [model]
                     (let [params (get models model)
                           s (snapshot.new provider model params)]
                       (append-context s)
                       (chat:set_snapshot s)
                       (chat:mount))))))}])
    (when chat-cfg.mappings
      (each [mode user-mappings (pairs chat-cfg.mappings)]
        (mappings.create_maps_to_plug false mode user-mappings "Neoai2Chat:")))))

{: setup}
