local provider = require("neoai2.api.provider")
local utils = require("neoai2.utils")

local M = {}

function M.new(provider, model, params)
    local snapshot = {
        messages = {},
    }

    M.set_model(snapshot, provider, model, params)

    return snapshot
end

function M.save(snapshot, path)
    local obj = {
        provider = snapshot.provider,
        model = snapshot.model,
        params = snapshot.params,
        messages = snapshot.messages,
    }

    local ok, err = utils.json.store(path)

    if not ok then
        return nil, err
    end

    return true
end

function M.load(path)
    local snapshot, err = utils.json.load(path)

    if not json then
        return nil, err
    end

    M.set_model(snapshot, snapshot.provider, snapshot.model, snapshot.params)

    return snapshot
end

function M.set_model(snapshot, user_provider, model, params)
    local provider_config = provider.config(user_provider)
    local model_config = provider_config.models[model]

    snapshot.provider = user_provider
    snapshot.provider_config = provider_config
    snapshot.model = model
    snapshot.params = params or model_config.default_params or {}
end

function M.append_message(snapshot, message)
    table.insert(snapshot.messages, message)
end

return M
