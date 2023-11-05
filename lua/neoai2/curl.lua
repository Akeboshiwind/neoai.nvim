local utils = require("neoai2.utils")

local M = {}

function M.stream(url, extra_args, on_stdout_chunk, on_complete)
    local stdout = vim.loop.new_pipe()
    function on_stdout_read(err, chunk)
        assert(not err, err)
        if chunk then
            vim.schedule(function()
                on_stdout_chunk(chunk)
            end)
        end
    end

    local stderr = vim.loop.new_pipe()
    local stderr_chunks = {}
    function on_stderr_read(err, chunk)
        assert(not err, err)
        if chunk then
            table.insert(stderr_chunks, chunk)
        end
    end

    local cmd = "curl"
    -- TODO: Comment: why these ops?
    local args = {
        "--silent",
        "--show-error",
        "--no-buffer",
        url,
    }
    args = utils.concat(args, extra_args)

    local handle
    handle, err_code = vim.loop.spawn(cmd, {
        args = args,
        stdio = { nil, stdout, stderr },
    }, function(code)
        stdout:close()
        stderr:close()
        handle:close()

        vim.schedule(function()
            if code ~= 0 then
                on_complete({
                    code = code,
                    msg = vim.trim(table.concat(stderr_chunks, "")),
                })
            else
                on_complete()
            end
        end)
    end)

    if not handle then
        on_complete({
            code = err_code,
            msg = "Could not be started",
        })
    else
        stdout:read_start(on_stdout_read)
        stderr:read_start(on_stderr_read)
    end

    return handle
end

function parse_events(input)
    local events = {}

    for _, event in ipairs(utils.split(input, "\n\n")) do
        -- TODO: filter out empty events
        if event == "" then
            goto continue
        end

        local data = {}
        for field in event:gmatch("[^\n]+") do
            if field:match("data:") then
                local part = vim.trim(field:gsub("data:", ""))
                table.insert(data, part)
            end
        end
        data = table.concat(data, "\n")

        -- TODO: parse other fields

        table.insert(events, {
            data = data,
        })

        ::continue::
    end

    return events
end

--- Stream Server Sent Events
-- https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
function M.stream_ss_events(url, extra_args, on_event, on_complete)
    local stdout_to_chunk = function(chunk)
        if chunk then
            for _, event in ipairs(parse_events(chunk)) do
                on_event(event)
            end
        end
    end

    return M.stream(url, extra_args, stdout_to_chunk, on_complete)
end

return M
