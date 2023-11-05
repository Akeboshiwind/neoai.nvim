-- "Stolen" from dressing.nvim
-- TODO: Properly attribute this & figure out licensing
local M = {}

M.create_plug_maps = function(bufnr, plug_bindings)
    for _, binding in ipairs(plug_bindings) do
        vim.keymap.set("", binding.plug, binding.rhs, { buffer = bufnr, desc = binding.desc, nowait = true })
    end
end

---@param bufnr number
---@param mode string
---@param bindings table<string, string|table>
---@param prefix string
M.create_maps_to_plug = function(bufnr, mode, bindings, prefix)
    for lhs, rhs in pairs(bindings) do
        if rhs then
            local opts = { buffer = bufnr, remap = true, nowait = true }
            if type(rhs) == "table" then
                for k, v in pairs(rhs) do
                    if type(k) == "string" then
                        opts[k] = v
                    elseif k == 1 then
                        rhs = v
                    end
                end
            end
            -- Prefix with <Plug> unless this is a <Cmd> or :Cmd mapping
            if type(rhs) == "string" then
                if not rhs:match("[<:]") then
                    rhs = "<Plug>" .. prefix .. rhs .. "<CR>"
                else
                    rhs = rhs .. "<CR>"
                end
                if mode == "i" then
                    rhs = "<C-o>" .. rhs
                end
            end
            vim.keymap.set(mode, lhs, rhs, opts)
        end
    end
end

return M
