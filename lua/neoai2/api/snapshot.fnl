(local {: autoload} (require :nfnl.module))
(local {: assoc : get-in} (autoload :nfnl.core))
(local provider (autoload :neoai2.api.provider))
(local utils (autoload :neoai2.utils))

(fn set-model [snapshot user-provider model params]
  (let [provider-config (provider.config user-provider)
        model-config (get-in provider-config [:models model])]
    (-> snapshot
        (assoc :provider user-provider)
        (assoc :provider_config provider-config)
        (assoc :model model)
        (assoc :params (or params
                           model-config.default_params
                           {})))))

(fn new [provider model params]
  (-> {:messages []}
      (set-model provider model params)))

(fn save [snapshot path]
  (let [obj {:messages snapshot.messages
             :model snapshot.model
             :params snapshot.params
             :provider snapshot.provider}
        (ok err) (utils.json.store obj path)]
    (if (not ok)
      (values nil err)
      true)))

(fn load [path]
  (let [(snapshot err) (utils.json.load path)]
    (if (not snapshot)
      (values nil err)
      (set-model snapshot snapshot.provider snapshot.model snapshot.params))))

(fn append-message [snapshot message]
  (table.insert snapshot.messages message)
  snapshot)

{: new
 : save
 : load
 :set_model set-model
 :append_message append-message}
