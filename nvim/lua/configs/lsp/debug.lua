local M = {}

-- Debug logging flag - set via vim.g.format_buffer_debug = true
local function is_debug_enabled()
    return vim.g.format_buffer_debug == true
end

function M.log(msg)
    if is_debug_enabled() then
        vim.notify("[format-buffer] " .. msg, vim.log.levels.DEBUG)
    end
end

-- Debug information for clang-format
function M.log_clang_format_info(current_file_name)
    if not is_debug_enabled() then
        return
    end

    local abs_path = vim.fn.expand("%:p")
    local cwd = vim.fn.getcwd()
    local project_root = vim.fs.root(0, ".git") or cwd

    M.log("Current file: " .. current_file_name)
    M.log("Absolute path: " .. abs_path)
    M.log("CWD: " .. cwd)
    M.log("Project root: " .. project_root)

    -- Check for .clang-format file
    local clang_format_file = vim.fs.find(".clang-format", {
        upward = true,
        path = vim.fn.expand("%:p:h"),
    })[1]

    if clang_format_file then
        M.log("Found .clang-format at: " .. clang_format_file)
    else
        M.log("WARNING: No .clang-format file found in parent directories")
    end
end

-- Debug information for prettier
function M.log_prettier_info(prettier_config, parser)
    if not is_debug_enabled() then
        return
    end

    M.log("Using prettier config: " .. prettier_config .. ", parser: " .. parser)
end

-- Log command execution
function M.log_command(cmd)
    if not is_debug_enabled() then
        return
    end

    M.log("Running command: " .. table.concat(cmd, " "))
end

return M
