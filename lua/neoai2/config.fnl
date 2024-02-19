(local {: autoload} (require :nfnl.module))
(local utils (autoload :neoai2.utils))
(local logger (autoload :neoai2.logger))

(fn get-api-key [config]
  (let [openai config.providers.openai]
    (or ; Get key from config
        openai.api-key
        ; Get key from environment
        (and openai.api-key-env (os.getenv openai.api-key-env))
        ; get key from command
        (and openai.api-key-cmd
             (let [cmd (vim.split openai.api-key-cmd " ")
                   key (vim.fn.system cmd)]
               (and (not (utils.shell_error))
                    (vim.trim key))))
        ; Otherwise error
        (let [msg "NeoAI failed to get api key from config environment and command"]
          (logger.error msg)
          (error msg)))))

(fn default-config []
  {:providers {:openai {:api-key nil
                        :api-key-env "OPENAI_API_KEY"
                        :api-key-cmd (.. "cat " (vim.fn.expand "$HOME") "/.config/openai/api_key")
                        :api-key-fn get-api-key
                        :models
                        {:gpt-3.5-turbo {}
                         :gpt-4 {}
                         :gpt-4-turbo-preview {}}}
               ;; TODO
               :ollama {}}
   :inject {:enabled false
            :default-model {:provider :openai
                            :model :gpt-3.5-turbo
                            :params {}}
            :mappings {"<leader>ai" {1 "Inject" :desc "NeoAi Inject"}
                       ; TODO: Cancel more than just injects?
                       "<C-c>" {1 "Cancel" :desc "NeoAi Cancel Inject"}}}
   :chat {:enabled false
          :tokens {:input "{input}"
                   :context "{context}"}
          :default-model {:provider :openai
                          :model :gpt-4-turbo-preview
                          :params {}}
          :mappings
          {:n {"<leader>ac" {1 "ToggleChat" :desc "NeoAI Toggle Chat"}
               "<leader>aC" {1 "NewChat" :desc "NeoAI New Chat"}
               "<leader>ap" {1 "ToggleChatSelectModel"}
               "<leader>aP" {1 "NewChatSelectModel"}}
           :v {"<leader>ac" {1 "ToggleChat" :desc "NeoAI Toggle Chat"}
               "<leader>aC" {1 "NewChat" :desc "NeoAI New Chat"}}}
          :input {:mappings
                  {:n {"<S-Enter>" {1 "SubmitPrompt" :desc "Submit Prompt"}
                       "<C-k>" {1 "SelectUp" :desc "Select Up"}
                       "<leader>aR" {1 "RegenerateLastPrompt" :desc "NeoAI Regenerate Last Prompt"}}
                   
                   :i {"<S-Enter>" {1 "SubmitPrompt" :desc "Submit Prompt"}}}}

          :output {:mappings
                   {:n {"<C-j>" {1 "SelectDown" :desc "Select Down"}}}}
          ; TODO: Add some defaults?}
          :prompts {}}})

(fn setup [opts]
  (let [opts (or opts {})
        config (vim.tbl_deep_extend "force" {} (default-config) opts)]
    (set config.providers.openai.api-key
         (config.providers.openai.api-key-fn config))
    config))

{: setup}
