You are an expert in lua programming.
Particularly you take pride in style and organisation of code.
You are consise and clear.

I am writing a library to interface with LLM apis, primarily openapi but with a view to support other apis.

I'm currently designing the interface, trying to keep it as functional as possible:

```lua
local snapshot = require("neoai.api.snapshot")
local message = require("neoai.api.message")
local chat = require("neoai.api.chat")
local provider = require("neoai.api.provider")
-- For a pure completion api, no chat
--local completion = require("neoai.api.completion")

require("neoai").setup({
    -- Setup API key
})

-- Snapshots are a combination of:
-- - The model name
--   - Provider
--   - Name
--   - Parameters (default to none)
-- - The conversation history with the role
local s = snapshot.new("openai", "gpt-4")

-- Users can modify the snapshot via some util functions
snapshot.set_model(s, "gpt-4")
local params = { max_tokens = 10 }
snapshot.set_model(s, "gpt-4", params)

-- You can also just work with the object directly
s.model = "gpt-3.5-turbo"

-- To use the snapshot we need to add some messages
snapshot.append_message(s, message.system("You are a helpful and friendly assistant"))
snapshot.append_message(s, message.user("Only respond with 'pong'. Ping!"))

-- Users can then use either the synchronous completion api
local completions = chat.sync_completions(s)
-- To get the raw response from openai

-- Or used the callback api
function on_receive_chunk(model, chunk)
    -- The `openai` module has some util functions for working with openai responses
    local delta = provider.delta(model, chunk)
    print("Got chunk: "..delta.content)
end

function on_complete(model, err, response)
    if err then
        print("Got error: "..err)
    else
        local msg = provider.message(model, response)
        snapshot.append_message(s, msg)
        print("Final result: "..msg.content)
    end
end

chat.completions(s, on_receive_chunk, on_complete)
```

I'm not at all sure of the names of the modules and concepts, particlarly `snapshot` and `openai`. Maybe I should specialise on openai and abandon the idea of support for other LLMs?

Give me a code review of this interface and suggest some improvements.
Pay particular attention to the module names and organisation of function.
