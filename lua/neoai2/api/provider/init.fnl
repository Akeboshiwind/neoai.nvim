(local {: autoload} (require :nfnl.module))
(local {: get-in : get} (require :nfnl.core))
(local logger (autoload :neoai2.logger))

(fn method [provider method]
  (let [mod (require (.. :neoai2.api.provider. provider))]
    (get-in mod method)))

(fn delta [provider chunk]
  (let [mthd (method provider [:utils :delta])]
    (if mthd
      (mthd chunk)
      (let [msg "Provider does not support getting a delta"]
        (logger.error msg)
        (error msg)))))

(fn message [provider chunk]
  (let [mthd (method provider [:utils :message])]
    (if mthd
      (mthd chunk)
      (let [msg "Provider does not support getting the message"]
        (logger.error msg)
        (error msg)))))

; TODO: I don't like this :/
;       Can we make it more functional?
(var provider-configs {})

(fn setup [config]
  (set provider-configs config.providers))

(fn config [provider]
  (get provider-configs provider))

{: method
 : delta
 : message
 : setup
 : config}
