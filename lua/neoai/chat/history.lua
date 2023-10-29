local config = require("neoai.config")

---@class ChatHistory
---@field model string The name of the model
---@field params table<string, string> The params for the model
---@field messages { role: "user" | "assistant", content: string }[] The message history
local ChatHistory = { model = "", params = {}, messages = {} }

---Create new chat history object
---@param model string The model to use
---@param params table<string, string> | nil The params for the model
---@param context string | nil The context to use
---@return ChatHistory
function ChatHistory:new(model, params, context)
    local obj = {}

    setmetatable(obj, self)
    self.__index = self

    self.model = model
    self.params = params or {}
    self.messages = {}

    if context ~= nil then
        local context_prompt = config.options.prompts.context_prompt(context)
        self:system(context_prompt)
    end
    return obj
end

---@param model string The model to use
---@param params table<string, string> | nil The params for the model
function ChatHistory:model(model, params)
    self.model = model
    self.params = params or {}
end

--- @param role string The role to set the prompt for
--- @param content string The content of the message added to the prompt
function ChatHistory:message(role, content)
    local message = {
        role = role,
        content = content,
    }
    table.insert(self.messages, message)
end

---@param content string The message to add
function ChatHistory:system(content)
    self:message("system", content)
end

---@param content string The message to add
function ChatHistory:user(content)
    self:message("user", content)
end

---@param content string The message to add
function ChatHistory:assistant(content)
    self:message("assistant", content)
end

return ChatHistory
