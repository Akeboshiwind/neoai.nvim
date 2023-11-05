-- TODO: Move to ui namespace?
local logger = require("neoai.logger")
local config = require("neoai2.config")
local snapshot = require("neoai2.api.snapshot")
local message = require("neoai2.api.message")
local chat = require("neoai2.api.chat")
local provider = require("neoai2.api.provider")
local utils = require("neoai2.utils")
local mappings = require("neoai2.mappings")

local M = {}

function M.inject(inject_cfg, prompt)
    local model = inject_cfg.default_model
    local s = snapshot.new(model.provider, model.model, model.params)
    snapshot.append_message(s, message.user(prompt))

    local has_made_change = false

    function on_receive_chunk(chunk)
        if chunk then
            local delta = provider.delta(s.provider, chunk)
            -- OpenAI returns a blank delta field in the last message, this ignores that
            if next(delta) then
                local content = {}
                -- delta.content is a string with `\n` characters
                -- nvim_put expects a list of lines
                for _, line in ipairs(utils.lines(delta.content)) do
                    table.insert(content, line)
                end

                -- Allow changes to be undone all at once
                if has_made_change then
                    vim.cmd([[undojoin]])
                end
                has_made_change = true

                vim.api.nvim_put(content, "c", true, true)
            end
        end
    end

    function on_complete(err, response)
        -- NOTE: This will also run when we run `cancel` later
        -- TODO: Put this "blank" binding in a global variable?
        local cancel_mappings = {
            {
                desc = "Cancel",
                plug = "<Plug>Neoai2Inject:Cancel",
                rhs = function() end,
            },
        }
        mappings.create_plug_maps(false, cancel_mappings)
    end

    -- NOTE: Handle is the return value of `vim.loop.spawn`
    local handle = chat.completions(s, on_receive_chunk, on_complete)

    -- Allow the user to cancel the injection
    function cancel()
        vim.loop.process_kill(handle)
        logger.info("Cancelled injection")
    end

    local cancel_mappings = {
        {
            desc = "Cancel",
            plug = "<Plug>Neoai2Inject:Cancel",
            rhs = cancel,
        },
    }
    mappings.create_plug_maps(false, cancel_mappings)
end

function M.setup(config)
    inject_cfg = config.inject

    if inject_cfg.enabled then
        local keymaps = {
            {
                desc = "Inject text",
                plug = "<Plug>Neoai2Inject:Inject",
                rhs = function()
                    local prompt = vim.fn.input("Neoai2> ")
                    M.inject(inject_cfg, prompt)
                end,
            },
            {
                desc = "Cancel Injection",
                plug = "<Plug>Neoai2Inject:Cancel",
                rhs = function() end,
            },
        }

        mappings.create_plug_maps(false, keymaps)
        mappings.create_maps_to_plug(false, "n", inject_cfg.mappings, "Neoai2Inject:")

        -- User Commands
        vim.api.nvim_create_user_command("Neoai2Inject", function(opts)
            local prompt
            if opts.args == "" then
                prompt = opts.args
            else
                prompt = vim.fn.input("Neoai2> ")
            end
            M.inject(inject_cfg, opts.args)
        end, {
            nargs = "*",
        })
    end
end

return M
