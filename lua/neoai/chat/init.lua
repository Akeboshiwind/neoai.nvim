local config = require("neoai.config")
local ChatHistory = require("neoai.chat.history")

local M = {}

---@type string | nil
M.context = nil

---@type ChatHistory
M.chat_history = nil
local append_to_output = nil

---@type {name: ModelModule, model: string, params: table<string, string> | nil}[] A list of models
M.models = {}
M.selected_model = 0

local setup_models = function()
    for _, model_obj in ipairs(config.options.models) do
        local raw_model = model_obj.model
        local models
        if type(raw_model) == "string" then
            models = { raw_model, }
        else
            models = raw_model
        end
        for _, model in ipairs(models) do
            table.insert(M.models, {
                name = require("neoai.chat.models." .. model_obj.name),
                model = model,
                params = model_obj.params,
            })
        end
    end
end

M.ensure_chat_history = function()
    if M.chat_history == nil then
        -- TODO: Allow loading most recent chat by default
        --       Or supply function to to choose
        --       Eg. Most recent chat, unless more than 1 day old
        M.new_chat_history()
        return true
    end
    return false
end

M.setup = function()
    setup_models()
    M.ensure_chat_history()
end

M.new_chat_history = function()
    local model = M.get_current_model()
    M.chat_history = ChatHistory:new(model.model, model.params, M.context)
end

M.select_next_model = function()
    local length = #M.models
    M.selected_model = (M.selected_model + 1) % length
    if not M.ensure_chat_history() then
        local model = M.get_current_model()
        M.chat_history:model(model.model, model.params)
    end
end

---Gets the current selected model
---@return { name: ModelModule, model: string, params: table<string, string> | nil } current_model The current model
M.get_current_model = function ()
    return M.models[M.selected_model+1]
end

---@param buffer number
---@param line1 number
---@param line2 number
M.set_context = function(buffer, line1, line2)
    local context = table.concat(vim.api.nvim_buf_get_lines(buffer, line1 - 1, line2, false), "\n")
    M.context = context
    M.ensure_chat_history()
end

M.reset_context = function()
    M.context = nil
end

M.reset = function()
    M.reset_context()
    M.chat_history = nil
end

local chunks = {}

M.get_current_output = function()
    return table.concat(chunks, "")
end

---Sends the prompt to the chat
---@param prompt string The prompt to send
---@param append_to_output_func fun(txt: string, type: integer) The function that will append the prompt to the output
---@param separators boolean True if separators should be included
---@param on_complete fun(output: string) Called when completed
M.send_prompt = function(prompt, append_to_output_func, separators, on_complete)
    append_to_output = function (txt, type)
        local ok, _ = pcall(append_to_output_func, txt, type)
    end
    if separators then
        append_to_output(prompt .. "\n\n--------\n\n", 1)
    end

    local on_stdout_chunk = function (chunk)
        append_to_output(chunk, 0)
    end

    local on_model_complete = function (err, output)
        if err ~= nil then
            vim.notify("NeoAI Error: " .. err, vim.log.levels.ERROR)
            return
        end
        if separators then
            append_to_output("\n\n--------\n\n", 1)
        end
        M.chat_history:assistant(output)
        on_complete(output)
    end

    M.chat_history:user(prompt)
    local send_to_model = M.get_current_model().name.send_to_model
    send_to_model(M.chat_history, on_stdout_chunk, on_model_complete)
end

return M
