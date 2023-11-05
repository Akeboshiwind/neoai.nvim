local provider = require("neoai2.api.provider")
local logger = require("neoai.logger")

local M = {}

function M.sync_completions(snapshot)
    local method = provider.method(snapshot.provider, { "chat", "sync_completions" })

    if method then
        return method(snapshot)
    else
        local msg = "Provider does not support sync completions"
        logger.error(msg)
        error(msg)
    end
end

function M.completions(snapshot, on_chunk, on_complete)
    local method = provider.method(snapshot.provider, { "chat", "completions" })

    if method then
        return method(snapshot, on_chunk, on_complete)
    else
        local msg = "Provider does not support async completions"
        logger.error(msg)
        error(msg)
    end
end

return M
