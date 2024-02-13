-- local config = require("neoai2.config")
-- local snapshot = require("neoai2.api.snapshot")
-- local message = require("neoai2.api.message")
-- local chat = require("neoai2.api.chat")
-- local provider = require("neoai2.api.provider")
-- local utils = require("neoai2.utils")
--
-- config.setup({
--     providers = {
--         openai = {
--             models = {
--                 ["gpt-3.5-turbo"] = {},
--                 ["gpt-4"] = {},
--             },
--         },
--     },
-- })

-- require("neoai2.inject").setup(config.config)
-- require("neoai2.ui.chat").setup(config.config)

-- require("neoai2.ui.chat.prompts")

local utils = require("neoai2.utils")
local message = require("neoai2.api.message")
local zip = require("zip")

function messages_zipper()
    local is_branch = function(node)
        return node ~= nil and node.children ~= nil
    end

    local children = function(node)
        return node.children
    end

    local make_node = function(node, children)
        print("node:")
        P(node)
        print("children:")
        P(children)
        local ret = utils.clone(node)

        print("ret:")
        P(ret)

        ret.children = children

        print("ret:")
        P(ret)

        return ret
    end

    local initial_node = {
        children = {},
    }

    return zip.zipper(is_branch, children, make_node, initial_node)
end

function append_message(zipper, message)
    local zipper = zip.append_child(zipper, message)
    zipper = zip.down(zipper)
    return zip.rightmost(zipper)
end

local messages = messages_zipper()

print("messages:")
P(messages)
-- print("children:")
-- P(zip.children(messages))

zip.append_child(messages, message.system("You are a friendly assistant."))

-- print("messages:")
-- P(messages)
-- print("is_branch:")
-- P(zip.is_branch(messages))
-- print("children:")
-- P(zip.children(messages))

if zip.down(messages) then
    P(messages)
else
    print("couldn't go down")
end

-- -- Normal session
-- messages = append_message(messages, message.system("You are a friendly assistant."))
-- messages = append_message(messages, message.user("What's the colour of the sky?"))
-- messages = append_message(messages, message.system("The colour of the sky is blue."))
--
-- -- User edit's their prompt
-- zip.up(messages)
-- zip.up(messages)
-- messages = append_message(messages, message.user("What colour is grass?"))
-- messages = append_message(messages, message.system("The colour of grass is green."))
--
-- -- User edit's the system messages
-- zip.up(messages)
-- zip.up(messages)
-- messages = append_message(messages, message.system("You are a helpful assistant."))
--
-- -- Later, we load up the session
-- local messages = zip.zipper
