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
                ["<leader>ai"] = "Inject",
                ["<C-c>"] = "Cancel",
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
                model = "gpt-3.5-turbo",
                params = {},
            },
            mappings = {
                n = {
                    ["<leader>aC"] = "NewChat",
                    ["<leader>ac"] = "ToggleChat",
                },
                v = {
                    ["<leader>aC"] = "NewChat",
                    ["<leader>ac"] = "ToggleChat",
                },
            },
            input = {
                mappings = {
                    n = {
                        ["<S-Enter>"] = "SubmitPrompt",
                        ["<C-k>"] = "SelectUp",
                        ["<leader>aR"] = "RegenerateLastPrompt",
                    },
                    i = {
                        ["<S-Enter>"] = "SubmitPrompt",
                    },
                },
            },
            output = {
                mappings = {
                    n = {
                        ["<C-j>"] = "SelectDown",
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
