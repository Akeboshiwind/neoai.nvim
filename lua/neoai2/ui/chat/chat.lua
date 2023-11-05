local snapshot = require("neoai2.api.snapshot")
local message = require("neoai2.api.message")
local chat = require("neoai2.api.chat")
local provider = require("neoai2.api.provider")
local utils = require("neoai2.utils")
local mappings = require("neoai2.mappings")

local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local ChatInput = require("neoai2.ui.chat.input")
local ChatOutput = require("neoai2.ui.chat.output")

local Chat = Layout:extend("Chat")

function Chat:init(s, config, layout_options)
    self.config = config
    self.snapshot = s

    self._mounted = false
    self._submitting = false

    self.input_popup = ChatInput()
    self.output_popup = ChatOutput(s.provider, s.model)

    local opts = {
        relative = "editor",
        position = {
            row = 0, -- TODO: Why does changing this do nothing?
            col = "100%",
        },
        size = {
            width = "30%",
            height = "100%",
        },
    }
    -- TODO: Swap out layout_options with self.config
    local options = vim.tbl_deep_extend("force", layout_options or {}, opts)

    -- TODO: Figure out how to allow the user to customise the layout
    Chat.super.init(
        self,
        options,
        Layout.Box({
            Layout.Box(self.output_popup, { size = "80%" }),
            Layout.Box(self.input_popup, { size = "20%" }),
        }, { dir = "col" })
    )
end

function Chat:rerender()
    self.output_popup:render_snapshot(self.snapshot)
    self.input_popup:clear()
end

function Chat:set_snapshot(snapshot)
    self.snapshot = snapshot

    if self:is_mounted() then
        self:rerender()
    end
end

function Chat:mount()
    if self._mounted then
        return
    end

    Chat.super.mount(self)

    self._mounted = true

    self:setup()
end

function Chat:unmount()
    if not self._mounted then
        return
    end

    Chat.super.unmount(self)

    self._mounted = false
end

-- TODO: Replace with property access?
--       So `chat.mounted` vs `chat:is_mounted()`
function Chat:is_mounted()
    return self._mounted
end

function Chat:toggle()
    if self:is_mounted() then
        self:unmount()
    else
        self:mount()
    end
end

function Chat:submit_input()
    local prompt = self.input_popup:lines()

    self.input_popup:clear()

    -- User prompt
    local user_message = message.user(table.concat(prompt, "\n"))
    snapshot.append_message(self.snapshot, user_message)
    self.output_popup:append_message(user_message)

    self:submit()
end

-- TODO: Rename?
function Chat:submit()
    if self._submitting then
        return
    end
    self._submitting = true

    -- TODO: Move to output_popup? Or at least a util module
    self.output_popup:append_lines({ "AI:", "" })

    function on_chunk(chunk)
        if chunk then
            local delta = provider.delta(self.snapshot.provider, chunk)
            if next(delta) then
                self.output_popup:append_string(delta.content)
            end
        end
    end

    function on_complete(err, result)
        if err then
            self.output_popup:append_lines({ "Error: " .. err })
        else
            local msg = provider.message(self.snapshot.provider, result)
            snapshot.append_message(self.snapshot, message.assistant(msg.content))
        end

        self.output_popup:append_lines({ "" })
        self._submitting = false
    end

    chat.completions(self.snapshot, on_chunk, on_complete)
end

function Chat:setup_keybinds()
    local keymaps = {
        {
            desc = "Select Up",
            plug = "<Plug>Neoai2Chat:SelectUp",
            rhs = function()
                vim.api.nvim_set_current_win(self.output_popup.winid)
            end,
        },
        {
            desc = "Select Down",
            plug = "<Plug>Neoai2Chat:SelectDown",
            rhs = function()
                vim.api.nvim_set_current_win(self.input_popup.winid)
            end,
        },
        {
            desc = "Submit",
            plug = "<Plug>Neoai2Chat:SubmitPrompt",
            rhs = function()
                self:submit_input()
            end,
        },
        {
            desc = "Regenerate Last Prompt",
            plug = "<Plug>Neoai2Chat:RegenerateLastPrompt",
            rhs = function()
                if self._submitting then
                    return
                end

                local last_message = self.snapshot.messages[#self.snapshot.messages]
                if not last_message or last_message.role ~= "assistant" then
                    return
                end

                self.snapshot.messages[#self.snapshot.messages] = nil

                self.output_popup:render_snapshot(self.snapshot)

                self:submit()
            end,
        },
    }

    mappings.create_plug_maps(false, keymaps)

    if self.config.input.mappings then
        local input_bufnr = self.input_popup.bufnr
        for mode, user_mappings in pairs(self.config.input.mappings) do
            mappings.create_maps_to_plug(input_bufnr, mode, user_mappings, "Neoai2Chat:")
        end
    end

    if self.config.output.mappings then
        local output_bufnr = self.output_popup.bufnr
        for mode, user_mappings in pairs(self.config.output.mappings) do
            mappings.create_maps_to_plug(output_bufnr, mode, user_mappings, "Neoai2Chat:")
        end
    end
end

function Chat:setup_events()
    self.input_popup:on(event.QuitPre, function()
        self:unmount()
    end)

    self.output_popup:on(event.QuitPre, function()
        self:unmount()
    end)
end

function Chat:setup()
    self:setup_keybinds()
    self:setup_events()

    self:rerender()
end

return Chat
