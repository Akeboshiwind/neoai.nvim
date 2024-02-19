(local {: autoload} (require :nfnl.module))
(local {: get-in : first} (autoload :nfnl.core))
(local logger (autoload :neoai2.logger))
(local curl (autoload :neoai2.curl))
(local u (autoload :neoai2.utils))


(local utils {})

(fn utils.delta [chunk]
  (get-in chunk [:choices 1 :delta]))

(fn utils.message [response]
  (get-in response [:choices 1 :message]))



(local chat {})

(local base-url "https://api.openai.com/v1")
(local chat-completions-url (.. base-url :/chat/completions))

(fn chat.sync_completions [snapshot]
  (let [api-key snapshot.provider_config.api-key
        data (vim.tbl_deep_extend :force
               {:messages snapshot.messages
                :model snapshot.model}
               snapshot.params)
        output (vim.fn.system
                 ["curl" "--silent" "--show-error" "--no-buffer"
                  chat-completions-url
                  "-H" "Content-Type: application/json"
                  "-H" (.. "Authorization: Bearer " api-key)
                  "-d" (vim.json.encode data)])]
    (if (u.shell_error)
      (values nil "Failed to run curl")
      (let [(ok json) (pcall vim.json.decode output)]
        (if (not ok)
          (values nil "Failed to decode JSON")
          json)))))

(fn merge-chunks [chunks]
  (if (= (first chunks) nil)
    {}
    (let [result (first chunks)]
      (set result.choices
        [(accumulate [out-choice {:message {}}
                      _ chunk (ipairs chunks)]
           (let [choice (first chunk.choices)
                 delta choice.delta]

             ; TODO: cond->
             (set out-choice.index choice.index)
             (set out-choice.finish_reason
                  choice.finish_reason)

             (when (not= delta.role nil)
               (set out-choice.message.role delta.role))

             (when (not= delta.content nil)
               (set out-choice.message.content
                    (.. (or out-choice.message.content "") delta.content)))
             out-choice))])
      result)))

(fn chat.completions [snapshot on-chunk on-complete]
  (let [api-key snapshot.provider_config.api-key
        params snapshot.params
        data (vim.tbl_deep_extend :force
               {:messages snapshot.messages
                :model snapshot.model
                :stream true}
               params)
        args ["-H" "Content-Type: application/json"
              "-H" (.. "Authorization: Bearer " api-key)
              "-d" (vim.json.encode data)]]

    (var chunks {})

    (fn on-event [event]
      (let [data event.data]
        (when (not (string.find data "%[DONE%]"))
          (let [(ok json) (pcall vim.json.decode data)]
            (if (or (not ok) (not= json.error nil))
              ; TODO: Don't just throw away errors?
              (logger.warning (.. "Failed to decode JSON: " data))
              (do (table.insert chunks json)
                  (on-chunk json)))))))

    (fn wrap-on-complete [err]
      (if (not= err nil)
        (on-complete err)
        (on-complete nil (merge-chunks chunks))))

    (curl.stream_ss_events chat-completions-url args on-event wrap-on-complete)))

{: utils
 : chat}
