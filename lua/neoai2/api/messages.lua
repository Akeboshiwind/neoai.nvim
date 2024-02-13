local M = {}

--- Given a list lists and tables, returns a flattened list.
function M.flatten(messages)
    local flattened = {}

    for _, message_or_list in ipairs(messages) do
        if message_or_list.content then
            local message = message_or_list
            table.insert(flattened, message)
        else
            local messages = message_or_list
            table.insert(flattened, messages[#messages])
        end
    end

    return flattened
end

-- TODO: Rename
local snapshot = {
    provider = "openai",
    model = "gpt-4-turbo",
    params = {},

    -- TODO: Rename
    messages = {
        path = {
            1, 2, 3,
        },
        tree = {
            roots = {
                {
                    role = "system",
                    content = "You are a helpful assistant.",
                    children = {
                        {
                            role = "user",
                            content = "What's the colour of the sky?",
                            children = {
                                {
                                    role = "user",
                                    content = "",
                                    children = {
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

local tree = {}

local my_tree = tree:new()
-- =>
-- {
--     roots = {},
--     cursor = nil 
-- }

tree.append_leaf(my_tree, message.system("You are a friendly assistant."))
-- =>
-- {
--     roots = {
--         {
--             role = "system",
--             content = "You are a friendly assistant."
--         },
--     },
--     cursor = { 1, },
-- }

tree.append_leaf(my_tree, message.user("What's the colour of the sky?"))
-- =>
-- {
--     roots = {
--         {
--             role = "system",
--             content = "You are a friendly assistant.",
--             children = {
--                 {
--                     role = "user",
--                     content = "What's the colour of the sky?",
--                 },
--             },
--         },
--     },
--     cursor = { 1, 1, },
-- }

tree.navigate(my_tree, {1, 2})
-- =>
-- {
--    roots = {
--        {
--            role = "system",
--            content = "You are a friendly assistant.",
--            children = {
--                {
--                    role = "user",
--                    content = "What's the colour of the sky?",
--                },
--             },
--         },
--     },
--     cursor = { 1, 2, },
-- }

tree.append_leaf(my_tree, message.user("What's a dog?"))
-- =>
-- {
--     roots = {
--         {
--             role = "system",
--             content = "You are a friendly assistant.",
--             children = {
--                 {
--                     role = "user",
--                     content = "What's the colour of the sky?",
--                 },
--                 {
--                     role = "user",
--                     content = "What's a dog?",
--                 },
--             },
--         },
--     },
--     cursor = { 1, 2, 2, },
-- }

{
    children = {
        {
            role = "system",
            content = "You are a friendly assistant.",
            children = {
                {
                    role = "user",
                    content = "What's the colour of the sky?",
                    children = {
                        {
                            role = "assistant",
                            content = "Blue!",
                            children = {
                            },
                        },
                    },
                },
                {
                    role = "user",
                    content = "What's a dog?",
                    children = {
                        {
                            role = "assistant",
                            content = "A dog is a dog.",
                            children = {
                            },
                        },
                    },
                },
            },
        },
        {
            role = "system",
            content = "You are a spelling robot.",
            children = {
            },
        },
    },
}


local zip = {
    -- Create
    zipper = function(is_branch, children, make_node, root)
        local z = { }
        return z
    end,

    -- Navigate
    down = function(loc)
    end,
    up = function(loc)
    end,
    left = function(loc)
    end,
    right = function(loc)
    end,
    leftmost = function(loc)
    end,
    rightmost = function(loc)
    end,

    -- Inspect
    node = function(loc)
        return loc[1]
    end,
    path = function(loc)
    end,
    root = function(loc)
    end,

    -- Edit
    append_child = function(loc)
    end,
}

function message_zipper(messages)
    return zip.zipper(
        function(n) return n.children end,
        function(n) return n.children end,
        function(x, children)
            x.children = children
            return x
        end,
        {
            children = messages,
        }
    )
end

function append_message(loc, message)
    zip.append_child(loc, message)
    zip.down(loc)
    zip.rightmost(loc)

    return loc
end

local z = message_zipper({ })

append_message(z, message.system("You are a helpful assistant."))
append_message(z, message.user("What's the colour of the sky?"))
append_message(z, message.assistant("Blue!"))

function xxx(z, idx, message)
    while
    return z
end

local messages = {
    {
        role = "system",
        content = "My initial prompt",
        next = {
            {
                role = "user",
                content = "My first message",
                next = {
                    {
                        role = "assistant",
                        content = "First assistant response",
                        next = {},
                    },
                },
            },
            {
                role = "user",
                content = "My altered message",
                next = {
                    {
                        role = "assistant",
                        content = "Second assistant response",
                        next = {},
                    },
                },
            },
        },
    },
}

local messages = {
    {
        role = "system",
        content = "My initial prompt",
    },
    {
        {
            role = "user",
            content = "My first message",
        },
        {
            role = "user",
            content = "My changed message",
        },
    },
    {
        {
            role = "assistant",
            content = "First assistant response",
        },
        {
            role = "assistant",
            content = "Second assistant response",
        },
    },
}

return M
