local utils = require("neoai2.utils")

local logger = require("neoai.logger")

local M = {}

function default_config()
    return {
        providers = {
            openai = {
                api_key = nil,
                api_key_env = "OPENAI_API_KEY",
                api_key_cmd = "cat " .. vim.fn.expand("$HOME") .. "/.config/openai/api_key",
                api_key_fn = function(config)
                    local openai = config.providers.openai

                    -- Get key from config
                    if openai.api_key then
                        return openai.api_key
                    end

                    -- Get key from environment
                    if openai.api_key_env then
                        local open_api_key = os.getenv(openai.api_key_env)

                        if open_api_key then
                            return open_api_key
                        end
                    end

                    -- Get key from command
                    if openai.api_key_cmd then
                        local cmd = utils.split(openai.api_key_cmd, " ")
                        local open_api_key = vim.fn.system(cmd)

                        if not utils.shell_error() then
                            return vim.trim(open_api_key)
                        end
                    end

                    -- Otherwise error
                    local msg = "NeoAI failed to get api key from config, environment and command"
                    logger.error(msg)
                    error(msg)
                end,

                models = {
                    ["gpt-3.5-turbo"] = {},
                    ["gpt-4"] = {},
                    ["gpt-4-turbo-preview"] = {},
                },
            },
            ollama = {
                -- TODO
            },
        },
        inject = {
            enabled = false,
            default_model = {
                provider = "openai",
                model = "gpt-3.5-turbo",
                params = {},
            },
            mappings = {
                ["<leader>ai"] = { "Inject", desc = "NeoAI Inject" },
                -- TODO: Cancel more than just injects?
                ["<C-c>"] = { "Cancel", desc = "NeoAI Cancel Inject" },
            },
        },
        chat = {
            enabled = false,
            tokens = {
                input = "{input}",
                context = "{context}",
            },
            default_model = {
                provider = "openai",
                model = "gpt-4-turbo-preview",
                params = {},
            },
            mappings = {
                n = {
                    ["<leader>ac"] = { "ToggleChat", desc = "NeoAI Toggle Chat" },
                    ["<leader>aC"] = { "NewChat", desc = "NeoAI New Chat" },
                    ["<leader>ap"] = { "ToggleChatSelectModel" },
                    ["<leader>aP"] = { "NewChatSelectModel" },
                },
                v = {
                    ["<leader>ac"] = { "ToggleChat", desc = "NeoAI Toggle Chat" },
                    ["<leader>aC"] = { "NewChat", desc = "NeoAI New Chat" },
                },
            },
            input = {
                mappings = {
                    n = {
                        ["<S-Enter>"] = { "SubmitPrompt", desc = "Submit Prompt" },
                        ["<C-k>"] = { "SelectUp", desc = "Select Up" },
                        ["<leader>aR"] = { "RegenerateLastPrompt", desc = "NeoAI Regenerate Last Prompt" },
                    },
                    i = {
                        ["<S-Enter>"] = { "SubmitPrompt", desc = "Submit Prompt" },
                    },
                },
            },
            output = {
                mappings = {
                    n = {
                        ["<C-j>"] = { "SelectDown", desc = "Select Down" },
                    },
                },
            },
            prompts = {
                -- TODO: Add some defaults?
            },
        },
    }
end

function M.setup(options)
    options = options or {}

    local config = vim.tbl_deep_extend("force", {}, default_config(), options)

    config.providers.openai.api_key = config.providers.openai.api_key_fn(config)

    return config
end

return M
