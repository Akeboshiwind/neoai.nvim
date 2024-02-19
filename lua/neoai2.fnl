; Provide three things:
; 1. Completion API
;   - Snapshot
;     - Append message
;     - Set model + params
;   - History (Improve name) (list of snapshots)
;     - Save/load
;     - Name?
;     - List
;   - Completion functions
;     - Streaming & not
;     - Callbacks:
;       - on_receive_chunk
;       - on_complete
;     - Chunk->MessageDelta (or something like this?)
;       - Maybe provide a wrapper function on_stdout_chunk
;         - Takes the chunks & outputs message deltas
; 2. Chat UI
;   - If not using don't require nui.nvim & Telescope
;   - Feat: Chat w/ context
;   - Provides UI for:
;     - Chat (view message history + send new message)
;       - Have an easy way to iterate on a prompt
;         - Limit to only the top level prompt?
;         - Or allow on any user input?
;       - Have a way to see the context
;         - key binding to toggle "system" box?
;     - History (view list of past conversations & load)
;     - Saved Prompts
;       - Different based on parameters
;         - W/ or w/o context
;         - In a buffer with a filetype?
;         - {
;               -- Can be either a string or a table of strings
;               prompt = "Start of prompt{input}End of prompt",
;               prompt = { "Start of prompt" "{input}" "End of prompt" },
;               model = {}
;                   provider = "openai",
;                   model = "gpt-4",
;                   parameters = { max_tokens = 10 },
;               
;
;               -- Can choose when this prompt is shown
;               -- When a context is provided
;               context_only = true,
;               -- When no context is provided
;               no_context_only = true,
;               -- When the buffer is a specific
;               filetypes = { "lua" },
;               -- Or can *override* all the above using this predicate
;               is_shown = function()
;                   return false
;               end,
;               -- Or disable the prompt entirely
;               -- (Not overridden by is_shown)
;               disabled = true,}
;           
;       - Allow prompts to specify where the cursor should be placed
;       - Prompts can set the model + params
;       - Always a new chat?
; 3. Examples
;   - Injection
;   - Telescope example (streaming & not?)

; ------------- Actual implementation -------------

(local {: autoload} (require :nfnl.module))
(local config (autoload :neoai2.config))
(local api-provider (autoload :neoai2.api.provider))
(local inject (autoload :neoai2.inject))
(local chat (autoload :neoai2.ui.chat))

(fn setup [opts]
  (let [opts (or opts {})
        ; TODO: Have this return the new config
        cfg (config.setup opts)]
    (doto cfg
       (api-provider.setup)
       (inject.setup)
       (chat.setup))))

{: setup}
