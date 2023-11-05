local logger = require("neoai.logger")
local curl = require("neoai2.curl")
local utils = require("neoai2.utils")

local M = {}

local base_url = "https://api.openai.com/v1"

M.utils = {}

function M.utils.delta(chunk)
    return chunk.choices[1].delta
end

function M.utils.message(response)
    return response.choices[1].message
end

M.chat = {}

local chat_completions_url = base_url .. "/chat/completions"

function M.chat.sync_completions(snapshot)
    local api_key = snapshot.provider_config.api_key

    local model = snapshot.model
    local params = snapshot.params
    local messages = snapshot.messages

    local data = {
        model = model,
        messages = messages,
    }
    data = vim.tbl_deep_extend("force", {}, data, params)

    local output = vim.fn.system({
        "curl",
        "--silent",
        "--show-error",
        "--no-buffer",
        chat_completions_url,
        "-H",
        "Content-Type: application/json",
        "-H",
        "Authorization: Bearer " .. api_key,
        "-d",
        vim.json.encode(data),
    })

    if utils.shell_error() then
        return nil, "Failed to run curl"
    end

    local ok, json = pcall(vim.json.decode, output)
    if not ok then
        return nil, "Failed to decode JSON"
    end

    return json
end

function merge_chunks(chunks)
    if chunks[1] == nil then
        return {}
    end

    local out_choice = {
        message = {},
    }

    for _, chunk in ipairs(chunks) do
        local choice = chunk.choices[1]
        local delta = choice.delta

        out_choice.index = choice.index
        out_choice.finish_reason = choice.finish_reason

        if delta.role ~= nil then
            out_choice.message.role = delta.role
        end

        if delta.content ~= nil then
            old_content = out_choice.message.content or ""
            out_choice.message.content = old_content .. delta.content
        end
    end

    local result = chunks[1]
    result.choices = { out_choice }

    return result
end

function M.chat.completions(snapshot, on_chunk, on_complete)
    local api_key = snapshot.provider_config.api_key

    local model = snapshot.model
    local params = snapshot.params
    local messages = snapshot.messages

    local data = {
        model = model,
        messages = messages,
        stream = true,
    }
    data = vim.tbl_deep_extend("force", {}, data, params)

    local args = {
        "-H",
        "Content-Type: application/json",
        "-H",
        "Authorization: Bearer " .. api_key,
        "-d",
        vim.json.encode(data),
    }

    local chunks = {}
    local on_event = function(event)
        local data = event.data

        if string.find(data, "%[DONE%]") then
            return
        end

        local ok, json = pcall(vim.json.decode, data)
        -- TODO: Don't just throw away errors?
        if not ok or json.error ~= nil then
            logger.warning("Failed to decode JSON: " .. data)
            return
        end

        table.insert(chunks, json)

        on_chunk(json)
    end

    local wrap_on_complete = function(err)
        if err ~= nil then
            on_complete(err)
        else
            on_complete(nil, merge_chunks(chunks))
        end
    end

    return curl.stream_ss_events(chat_completions_url, args, on_event, wrap_on_complete)
end

return M
