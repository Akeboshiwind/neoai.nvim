local M = {}

function M.concat(a, ...)
    local out = { unpack(a) }

    for _, tbl in ipairs({ ... }) do
        for _, v in ipairs(tbl) do
            table.insert(out, v)
        end
    end

    return out
end

function M.clone(tbl)
    local ret = {}

    -- Keyed entries.
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            ret[k] = M.clone(v)
        else
            ret[k] = v
        end
    end

    -- Indexed entries.
    for k, v in ipairs(tbl) do
        if type(v) == "table" then
            ret[k] = M.clone(v)
        else
            ret[k] = v
        end
    end

    return ret
end

-- TODO: replace with vim.split(input, delimiter, {plain=true, trimempty=true})
function M.split(input, delimiter)
    local result = {}
    local start = 1

    local split_start, split_end

    while true do
        split_start, split_end = string.find(input, delimiter, start, true)

        if not split_start then
            table.insert(result, string.sub(input, start))
            break
        end

        table.insert(result, string.sub(input, start, split_start - 1))
        start = split_end + 1
    end

    return result
end

function M.lines(str)
    return M.split(str, "\n")
end

function M.shell_error()
    return vim.v.shell_error ~= 0
end

function M.is_buf_empty(bufnr)
    -- NOTE: `nvim_buf_get_lines` will return an empty string for the first
    --       line of an empty buffer.
    --       Instead we get the first two lines, if only one line is returned
    --       **and** it is empty, then we know the buffer is empty.
    local start_of_buf = vim.api.nvim_buf_get_lines(bufnr, 0, 2, false)
    return #start_of_buf == 1 and start_of_buf[1] == ""
end

-- Hacked together from:
-- https://github.com/nvim-telescope/telescope.nvim/pull/2333/files#diff-28bcf3ba7abec8e505297db6ed632962cbbec357328d4e0f6c6eca4fac1c0c48R170
function M.selection()
    local mode = vim.fn.mode()
    if not (mode == "v" or mode == "V") then
        return nil
    end

    local saved_reg = vim.fn.getreg("v")

    vim.cmd([[noautocmd sil norm "vy]])

    local selection = vim.fn.getreg("v")

    vim.fn.setreg("v", saved_reg)

    return selection
end

M.json = {}

function M.json.store(obj, path)
    local ok, file_contents = pcall(vim.json.encode, obj)

    if not ok then
        local err = "Failed to encode json: " .. file_contents
        return false, err
    end

    local ok, err = pcall(vim.fn.writefile, { file_contents }, path)

    if not ok then
        return false, err
    end

    return true
end

function M.json.load(path)
    local ok, file_contents = pcall(vim.fn.readfile, path)

    if not ok then
        local err = file_contents
        return nil, err
    end

    file_contents = table.concat(file_contents, "\n")

    local ok, obj = pcall(vim.json.decode, file_contents)

    if not ok then
        local err = "Failed to decode json: " .. obj
        return nil, err
    end

    return obj
end

return M
