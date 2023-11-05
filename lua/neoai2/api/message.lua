local M = {}

function message(role, content)
    return {
        role = role,
        content = content,
    }
end

function M.system(content)
    return message("system", content)
end

function M.user(content)
    return message("user", content)
end

function M.assistant(content)
    return message("assistant", content)
end

return M
