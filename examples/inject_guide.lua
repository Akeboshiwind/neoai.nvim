local snapshot = require("neoai2.api.snapshot")
local message = require("neoai2.api.message")
local chat = require("neoai2.api.chat")

require("neoai2").setup({})

-- First let's make a new snapshot
-- This contains:
-- - The model and it's params
-- - and the message history
local s = snapshot.new("openai", "gpt-3.5-turbo")
-- {
--     provider = "openai",
--     model = "gpt-3.5-turbo",
--     params = nil,
--     messages = {},
-- }

-- Or you can load it from a file
--local s = snapshot.load("/tmp/test/snapshot.json")

-- You can set the model and params using the model function
-- Params are merged into the base of the request to the model
-- See: https://platform.openai.com/docs/api-reference/chat/create
snapshot.set_model(s, "openai", "gpt-4")
snapshot.set_model(s, "openai", "gpt-4", { max_tokens = 10 })

-- NOTE: Don't set the provider or model directly on the snapshot as this is where we pull in the api key and default_params

-- You can also save a snapshot to a file
snapshot.save(s, "/tmp/test/snapshot.json")

-- Now let's actually use the snapshot
-- Let's add some messages:
snapshot.append_message(s, message.system("You are a friendly and helpful assistant."))
snapshot.append_message(s, message.user("Hello! Please reply with 'hi' if you understand me :)"))

-- Nothing stops you from adding multiple system messages
snapshot.append_message(s, message.system("You are a friendly dog, you can only reply with 'woof'."))

-- Or assistant messages
-- snapshot.append_message(s, message.assistant("You are a friendly dog, you can only reply with 'woof'."))

-- That's all very nice, but we actually want to get something from chatgpt.
local completions = chat.sync_completions(s)

-- The response will depend on the provider you select
-- In this case it's just the response from the openai api
-- {
--     id = "chatcmpl-123",
--     ...
--     choices = {
--         {
--             index = 0,
--             message = {
--                 role = "assistant",
--                 content = "Woof!",
--             },
--             finish_reason = "stop",
--         },
--     },
--     usage = {
--         ...
--     }
-- }

-- This request will block the UI though, so let's use callback api

-- First we need to setup the callbacks
-- One to receive streamed results:
function on_receive_chunk(chunk)
    print("Got chunk!")
end

-- Chunks look like this:
-- {
--     id = "chatcmpl-123",
--     object = "chat.completion.chunk",
--     created = 1694268190,
--     model = "gpt-3.5-turbo-0613",
--     choices = {
--         {
--             index = 0,
--             delta = {
--                 role = "assistant",
--                 content = "I am ",
--             },
--             finish_reason = nil,
--         },
--     }
-- }

-- Another to receive the final result
function on_complete(model, err, response)
    if err then
        print("Got error!")
        print(err)
    else
        print("Got result!")
    end
end

-- The final result looks like:
-- {
--     id = "chatcmpl-123",
--     object = "chat.completion.chunk",
--     created = 1694268190,
--     model = "gpt-3.5-turbo-0613",
--     choices = {
--         {
--             index = 0,
--             message = {
--                 role = "assistant",
--                 content = "I am a dog, woof!"
--             },
--             finish_reason = "stop",
--         },
--     }
-- }
-- NOTE: This result is built from the deltas seen in the above chunk

-- Finally we call the callback function
chat.completions(s, on_receive_chunk, on_complete)

-- As a convenience, there are a couple of functions to work with responses
local provider = require("neoai2.api.provider")

-- One to get content delta from a chunk (the bit you probably want)
-- provider.delta(s.provider, chunk1).content
-- => "I am"
-- provider.delta(s.provider, chunk2).content
-- => " a dog"

-- Another to get the message from a result
-- provider.message(s.provider, response)
-- => {
--        role = "assistant",
--       content = "I am a dog, woof!",
--    }
-- This can be used directly with the snapshot from earlier to update it with the most recent response
-- snapshot.append_message(s, provider.message(s.provider, response))

-- There are also provider specific modules which the `provider` module just calls into
-- These might be useful if there are details specific to a provider orif you *know* you'll only ever work with one provider
local openai = require("neoai2.api.provider.openai")

-- Let's actually pull this together to something useful
-- Let's implement injecting the assistant's response into the buffer

local snapshot = require("neoai2.api.snapshot")
local message = require("neoai2.api.message")
local chat = require("neoai2.api.chat")
local provider = require("neoai2.api.provider")

require("neoai2").setup({
    -- Left as an exercise to the reader
})

-- TODO: This is **aaalllll** pseudocode, actually get working etc
function inject(prompt)
    -- Setup the snapshot to send to openai
    local s = snapshot.new("openai", "gpt-4")
    snapshot.append_message(s, message.user(prompt))

    -- When we receive a chunk, add it to the current buffer before the cursor
    local on_receive_chunk = function(chunk)
        local delta = provider.delta(s.provider, chunk)
        vim.api.nvim_put({ delta.content }, "c", true, true)
    end

    -- Defined later
    local cancel_fn = nil

    -- Allow the user to cancel the injection
    -- TODO: Fix this
    vim.api.nvim_set_keymap("i", "<C-c>", "<cmd>lua cancel_fn()<CR>", { noremap = true, silent = true })

    -- When we're done, remove the keymap
    local on_complete = function(model, err, response)
        vim.api.nvim_set_keymap("i", "<C-c>", "<ESC>", { noremap = true, silent = true })
    end

    -- Actually send the request
    -- NOTE: `completions` returns a function to allow us to cancel the request
    cancel_fn = chat.completions(s, on_receive_chunk, on_complete)
end

-- Bind to a user command
vim.api.nvim_create_user_command("MyCustomInject", function(opts)
    inject(opts.args)
end, {
    nargs = "*",
})

return {}
