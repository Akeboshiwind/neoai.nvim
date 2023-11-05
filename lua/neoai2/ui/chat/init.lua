local snapshot = require("neoai2.api.snapshot")
local message = require("neoai2.api.message")
local mappings = require("neoai2.mappings")
local utils = require("neoai2.utils")

local Chat = require("neoai2.ui.chat.chat")

local M = {}

function default_snapshot(config)
    local model = config.default_model

    return snapshot.new(model.provider, model.model, model.params)
end

function append_context(s)
    local context = utils.selection()
    if context then
        local content = "Given the following as context:\n" .. context
        snapshot.append_message(s, message.system(content))
    end
end

function M.setup(config)
    local chat_cfg = config.chat

    local chat = Chat(default_snapshot(chat_cfg), chat_cfg)

    local keymaps = {
        {
            desc = "Toggle Chat window",
            plug = "<Plug>Neoai2Chat:ToggleChat",
            rhs = function()
                append_context(chat.snapshot)

                chat:toggle()
            end,
        },
        {
            desc = "New Chat Window",
            plug = "<Plug>Neoai2Chat:NewChat",
            rhs = function()
                local s = default_snapshot(chat_cfg)

                append_context(s)

                chat:set_snapshot(s)

                chat:mount()
            end,
        },
    }

    mappings.create_plug_maps(false, keymaps)

    if chat_cfg.mappings then
        for mode, user_mappings in pairs(chat_cfg.mappings) do
            mappings.create_maps_to_plug(false, mode, user_mappings, "Neoai2Chat:")
        end
    end
end

return M
