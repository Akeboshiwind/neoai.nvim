-- [nfnl] Compiled from lua/neoai2/config.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local utils = autoload("neoai2.utils")
local logger = autoload("neoai2.logger")
local function get_api_key(config)
  local openai = config.providers.openai
  local function _2_()
    local cmd = vim.split(openai["api-key-cmd"], " ")
    local key = vim.fn.system(cmd)
    return (not utils.shell_error() and vim.trim(key))
  end
  local function _3_()
    local msg = "NeoAI failed to get api key from config environment and command"
    logger.error(msg)
    return error(msg)
  end
  return (openai["api-key"] or (openai["api-key-env"] and os.getenv(openai["api-key-env"])) or (openai["api-key-cmd"] and _2_()) or _3_())
end
local function default_config()
  return {providers = {openai = {["api-key"] = nil, ["api-key-env"] = "OPENAI_API_KEY", ["api-key-cmd"] = ("cat " .. vim.fn.expand("$HOME") .. "/.config/openai/api_key"), ["api-key-fn"] = get_api_key, models = {["gpt-3.5-turbo"] = {}, ["gpt-4"] = {}, ["gpt-4-turbo-preview"] = {}}}, ollama = {}}, inject = {["default-model"] = {provider = "openai", model = "gpt-3.5-turbo", params = {}}, mappings = {["<leader>ai"] = {"Inject", desc = "NeoAi Inject"}, ["<C-c>"] = {"Cancel", desc = "NeoAi Cancel Inject"}}, enabled = false}, chat = {tokens = {input = "{input}", context = "{context}"}, ["default-model"] = {provider = "openai", model = "gpt-4-turbo-preview", params = {}}, mappings = {n = {["<leader>ac"] = {"ToggleChat", desc = "NeoAI Toggle Chat"}, ["<leader>aC"] = {"NewChat", desc = "NeoAI New Chat"}, ["<leader>ap"] = {"ToggleChatSelectModel"}, ["<leader>aP"] = {"NewChatSelectModel"}}, v = {["<leader>ac"] = {"ToggleChat", desc = "NeoAI Toggle Chat"}, ["<leader>aC"] = {"NewChat", desc = "NeoAI New Chat"}}}, input = {mappings = {n = {["<S-Enter>"] = {"SubmitPrompt", desc = "Submit Prompt"}, ["<C-k>"] = {"SelectUp", desc = "Select Up"}, ["<leader>aR"] = {"RegenerateLastPrompt", desc = "NeoAI Regenerate Last Prompt"}}, i = {["<S-Enter>"] = {"SubmitPrompt", desc = "Submit Prompt"}}}}, output = {mappings = {n = {["<C-j>"] = {"SelectDown", desc = "Select Down"}}}}, prompts = {}, enabled = false}}
end
local function setup(opts)
  local opts0 = (opts or {})
  local config = vim.tbl_deep_extend("force", {}, default_config(), opts0)
  config.providers.openai["api-key"] = config.providers.openai["api-key-fn"](config)
  return config
end
return {setup = setup}
