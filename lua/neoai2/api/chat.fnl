(local {: autoload} (require :nfnl.module))
(local provider (autoload :neoai2.api.provider))
(local logger (autoload :neoai2.logger))

(fn sync-completions [snapshot]
  (let [method (provider.method snapshot.provider
                                [:chat :sync_completions])]
    (if method
      (method snapshot)
      (let [msg "Provider does not support sync completions"]
        (logger.error msg)
        (error msg)))))

(fn completions [snapshot on-chunk on-complete]
  (let [method (provider.method snapshot.provider
                                [:chat :completions])]
    (if method
      (method snapshot on-chunk on-complete)
      (let [msg "Provider does not support async completions"]
        (logger.error msg)
        (error msg)))))

{:sync_completions sync-completions
 : completions}
