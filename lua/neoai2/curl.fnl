(local {: autoload} (require :nfnl.module))
(local utils (autoload :neoai2.utils))

(fn stream [url extra-args on-stdout-chunk on-complete]
  (let [stdout (vim.loop.new_pipe)
        stderr (vim.loop.new_pipe)

        stderr-chunks []
        on-stderr-read
        (fn [err chunk]
          (assert (not err) err)
          (when chunk
            (table.insert stderr-chunks chunk)))

        cmd "curl"
        args (utils.concat ["--silent" "--show-error" "--no-buffer" url]
                           extra-args)

        (handle err-code)
        (vim.loop.spawn cmd
          {:args args
           :stdio [nil stdout stderr]}
          (fn [code]
            (stdout:close)
            (stderr:close)
            ; Not a real error, just something fennel-language-server doesn't support
            ; WARN: Don't fix with a `handle nil` because of scoping issues
            (handle:close)
            (vim.schedule
              #(if (not= 0 code)
                 (on-complete {:code code
                               :msg (-> stderr-chunks
                                        (table.concat "")
                                        (vim.trim))})
                 (on-complete)))))]
    (if (not handle)
      (on-complete {:code err-code
                    :msg "Could not be started"})
      (do (stdout:read_start
            (fn [err chunk]
              (assert (not err) err)
              (when chunk
                (vim.schedule #(on-stdout-chunk chunk)))))
          (stderr:read_start on-stderr-read)))
    handle))

(fn parse-events [input]
  ;; Events are separated by two newline characters
  (icollect [_ event (-> input (utils.split "\n\n") ipairs)]
    (when (not= "" event)
      (let [data (icollect [field (event:gmatch "[^\n]+")]
                   ; TODO: parse other fields
                   (when (field:match "^data:")
                     (-> field
                         (: :gsub "data:"  "")
                         vim.trim)))
            data (table.concat data "\n")]
        {: data}))))

;; Stream Server Sent Events
; https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
(fn stream-ss-events [url extra-args on-event on-complete]
  (stream url
          extra-args
          (fn [chunk]
            (when chunk
              (each [_ event (-> chunk parse-events ipairs)]
                (on-event event))))
          on-complete))

{: stream
 :stream_ss_events stream-ss-events}
