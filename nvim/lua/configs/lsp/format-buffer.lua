local filetypes = require("utils.filetypes")
local formatters = require("utils.formatters")
local debug = require("configs.lsp.debug")

local clang_types = {
    filetypes.c,
    filetypes.cpp,
    filetypes.arduino,
}

local prettier_types = {
    filetypes.javascript,
    filetypes.typescript,
    filetypes.jsx,
    filetypes.tsx,
    filetypes.json,
    filetypes.css,
}

-- List of all possible prettier config file names
local prettier_config_files = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
}

local function find_prettier_config(root_path)
    for _, config_file in ipairs(prettier_config_files) do
        local config_path = vim.fn.resolve(root_path .. "/" .. config_file)

        if vim.fn.filereadable(config_path) == 1 then
            return config_path
        end
    end

    return nil
end

--- Format current buffer based on filetype. Fallbacks to nvim-lsp formatter.
return function()
    local filetype = vim.bo.filetype
    local current_file_name = vim.fn.expand("%")

    debug.log("Starting format for filetype: " .. filetype .. ", file: " .. current_file_name)

    -- [[ Markdown ]]
    if filetype == filetypes.markdown then
        debug.log("Skipping markdown formatting")
        return
    end

    -- [[ C/C++/Arduino ]]
    if vim.tbl_contains(clang_types, filetype) then
        debug.log("Formatting C/C++/Arduino with clang-format")
        if vim.fn.executable("clang-format") ~= 1 then
            vim.notify("clang-format is not installed, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end

        debug.log_clang_format_info(current_file_name)

        local project_root = vim.fs.root(0, { ".git", ".clang-format" })
        local clang_format_file = project_root and project_root .. "/.clang-format"
        local cmd = { "clang-format" }

        if clang_format_file and vim.fn.filereadable(clang_format_file) == 1 then
            table.insert(cmd, "--style=file:" .. clang_format_file)
        end

        table.insert(cmd, current_file_name)

        debug.log_command(cmd)

        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("clang-format failed for " .. current_file_name, vim.log.levels.ERROR)
            return
        end

        debug.log("clang-format completed successfully")
        return
    end

    -- [[ Go ]]
    if filetype == filetypes.go then
        debug.log("Formatting Go with gofumpt and golines")
        if vim.fn.executable("gofumpt") ~= 1 then
            vim.notify("gofumpt is not installed, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end

        local cmd = { "gofumpt", current_file_name }
        debug.log_command(cmd)

        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("gofumpt failed for " .. current_file_name, vim.log.levels.ERROR)
            return
        end

        debug.log("gofumpt completed successfully")

        cmd = {
            "golines",
            current_file_name,
            "--max-len=80",
            "--ignore-generated",
            "--ignored-dirs=vendor,node_modules",
        }

        debug.log_command(cmd)
        ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("golines failed for " .. current_file_name, vim.log.levels.ERROR)
            return
        end

        debug.log("golines completed successfully")
        return
    end

    -- [[ Lua ]]
    if filetype == filetypes.lua then
        debug.log("Formatting Lua with stylua")
        local ok, stylua = pcall(require, "stylua-nvim")

        if not ok then
            vim.notify("Stylua is not installed, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end

        stylua.format_file()
        debug.log("stylua completed successfully")

        return
    end

    -- [[ JS/TS/Json/CSS ]]
    if vim.tbl_contains(prettier_types, filetype) then
        debug.log("Formatting JS/TS/JSON/CSS with prettierd")
        if vim.fn.executable("prettierd") ~= 1 then
            vim.notify("Prettierd is not installed, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end

        local parser = "babel"
        if string.find(filetype, "typescript") then
            parser = parser .. "-ts"
        end

        local project_root = vim.fs.root(0, ".git") or "./"
        local prettier_config = find_prettier_config(project_root)

        if prettier_config == nil then
            vim.notify("Prettier configuration file could not be found, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end

        debug.log_prettier_info(prettier_config, parser)

        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local buf_content = table.concat(lines, "\n")

        -- sh -c echo [file contents] | /usr/local/bin/prettierd --no-color --parser=[parser] [filename]
        local cmd = {
            "sh",
            "-c",
            "printf %s "
                .. vim.fn.shellescape(buf_content)
                .. " | prettierd "
                .. "--no-color --parser="
                .. parser
                .. " --stdin-filepath "
                .. vim.fn.shellescape(current_file_name),
        }
        local env = { PRETTIERD_DEFAULT_CONFIG = prettier_config }

        debug.log("Running prettierd via shell")
        local ok = formatters.run_command_on_buffer(cmd, env)

        if not ok then
            vim.notify("prettierd failed for " .. current_file_name, vim.log.levels.ERROR)
            goto FALLBACK
        end

        debug.log("prettierd completed successfully")
        return
    end

    -- [[ Templ ]]
    if filetype == filetypes.templ then
        debug.log("Formatting Templ with templ fmt")
        if vim.fn.executable("templ") ~= 1 then
            vim.notify("Templ is not installed, using LSP formatter", vim.log.levels.ERROR)
            goto FALLBACK
        end
        local cmd = {
            "templ",
            "fmt",
            "-stdout",
            "-log-level",
            "error",
            current_file_name,
        }
        debug.log_command(cmd)
        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("templ fmt failed for " .. current_file_name, vim.log.levels.ERROR)
            goto FALLBACK
        end

        debug.log("templ fmt completed successfully")
        return
    end

    -- [[ WebC ]]
    if filetype == filetypes.webc then
        debug.log("Formatting WebC with LSP (skipping frontmatter)")
        formatters.lsp_format_skip_frontmatter()
        debug.log("WebC formatting completed")

        return
    end

    -- [[ Nix ]]
    if filetype == filetypes.nix then
        debug.log("Formatting Nix with nixfmt")
        if vim.fn.executable("nixfmt") ~= 1 then
            vim.notify("nixfmt is not installed, skipping formatting", vim.log.levels.ERROR)
            return
        end

        -- FIXME: on NixOS, cannot find `_system.lua`
        local cmd = {
            "nixfmt <",
            "-w 80",
            current_file_name,
        }

        debug.log_command(cmd)
        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("nixfmt failed for " .. current_file_name, vim.log.levels.ERROR)
            goto FALLBACK
        end

        debug.log("nixfmt completed successfully")
        return
    end

    -- [[ Rust ]]
    if filetype == filetypes.rust then
        debug.log("Formatting Rust with rustfmt")
        if vim.fn.executable("rustfmt") ~= 1 then
            vim.notify("rustfmt is not installed, skipping formatting", vim.log.levels.ERROR)
            return
        end

        local cmd = {
            "rustfmt",
            "--emit=stdout",
            "--color=never",
            -- rustfmt likes to print the path to the file above the output
            "--quiet",
            current_file_name,
        }

        debug.log_command(cmd)
        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("rustfmt failed, could not format " .. current_file_name, vim.log.levels.ERROR)
            return
        end

        debug.log("rustfmt completed successfully")
        return
    end

    -- [[ SQL ]]
    if filetype == filetypes.sql then
        debug.log("Formatting SQL with pg_format")
        if vim.fn.executable("pg_format") ~= 1 then
            vim.notify("pg_format is not installed, skipping formatting", vim.log.levels.ERROR)
            return
        end

        local cmd = {
            "pg_format",
            "-w",
            "80",
            "--function-case",
            "2",
            "--type-case",
            "2",
            "--no-space-function",
            "--comma-start",
            "--comma-break",
            "--no-rcfile",
            current_file_name,
        }

        debug.log_command(cmd)
        local ok = formatters.run_command_on_buffer(cmd)

        if not ok then
            vim.notify("pg_format failed for " .. current_file_name, vim.log.levels.ERROR)
            return
        end

        debug.log("pg_format completed successfully")
        return
    end

    -- [[ Fallback ]]
    ::FALLBACK::
    debug.log("Using LSP fallback formatter")
    vim.lsp.buf.format()
    debug.log("LSP formatting completed")
end
