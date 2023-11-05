local logger = require("neoai.logger")

local M = {}

function M.method(provider, method)
    local module = require("neoai2.api.provider." .. provider)

    local result = module
    for _, part in ipairs(method) do
        if result[part] then
            result = result[part]
        else
            return
        end
    end

    return result
end

function M.delta(provider, chunk)
    local method = M.method(provider, { "utils", "delta" })
    if method then
        return method(chunk)
    else
        local msg = "Provider does not support getting a delta"
        logger.error(msg)
        error(msg)
    end
end

function M.message(provider, chunk)
    local method = M.method(provider, { "utils", "message" })
    if method then
        return method(chunk)
    else
        local msg = "Provider does not support getting the message"
        logger.error(msg)
        error(msg)
    end
end

-- TODO: I don't like this :/
--       Can we make it more functional?
local provider_configs = {}

function M.setup(config)
    provider_configs = config.providers
end

function M.config(provider)
    return provider_configs[provider]
end

return M
