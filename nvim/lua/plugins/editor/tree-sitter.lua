-- Patch nvim-treesitter's query_predicates.lua and query.lua to handle
-- TSNode[] arrays. The master branch is archived and its match-API
-- directives break on Neovim 0.12+ which passes TSNode[] (instead of a
-- single TSNode) to handlers. Symptoms:
--   * markdown fenced code blocks: "attempt to call method 'range' (a nil value)"
--   * textobjects moves (]m, [m, etc.): same error, jumps don't work
local function patch_file(path, marker, replacements)
    local f = io.open(path, "r")
    if not f then
        return
    end
    local content = f:read("*a")
    f:close()
    if content:find(marker, 1, true) then
        return
    end
    local total = 0
    for _, r in ipairs(replacements) do
        local patched, n = content:gsub(r[1], r[2])
        content = patched
        total = total + n
    end
    if total == 0 then
        return
    end
    content = marker .. "\n" .. content
    local out = io.open(path, "w")
    if not out then
        return
    end
    out:write(content)
    out:close()
end

local function patch_nvim_treesitter()
    local data = vim.fn.stdpath("data")
    -- Unwrap TSNode[] → TSNode in query_predicates.lua
    patch_file(
        data .. "/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua",
        "--PATCHED_TSNODE_ARRAY--",
        {
            {
                "(local node = )(match%b[])",
                "%1(function(v) if type(v)=='table' then return v[1] end return v end)(%2)",
            },
        }
    )
    -- Unwrap TSNode[] → TSNode in query.lua (iter_prepared_matches),
    -- fixes textobjects moves (]m, [m, ]], [[, etc.) on Neovim 0.12+.
    patch_file(
        data .. "/lazy/nvim-treesitter/lua/nvim-treesitter/query.lua",
        "--PATCHED_TSNODE_ARRAY--",
        {
            {
                "for id, node in pairs%(match%) do",
                "for id, node in pairs(match) do if type(node)=='table' then node = node[1] end",
            },
            {
                "tsrange%.TSRange%.from_nodes%(bufnr, match%[pred%[3%]%], match%[pred%[4%]%]%)",
                "tsrange.TSRange.from_nodes(bufnr, (function(v) if type(v)=='table' then return v[1] end return v end)(match[pred[3]]), (function(v) if type(v)=='table' then return v[1] end return v end)(match[pred[4]]))",
            },
        }
    )
end

return {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/playground",
        "vrischmann/tree-sitter-templ",
    },
    build = function()
        vim.cmd("TSUpdate")
        patch_nvim_treesitter()
    end,
    init = function()
        patch_nvim_treesitter()
    end,
    config = function()
        -- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
        vim.defer_fn(function()
            require("nvim-treesitter.configs").setup({
                -- Add languages to be installed here that you want installed for treesitter
                ensure_installed = {
                    "bash",
                    "c",
                    "comment",
                    "cpp",
                    "css",
                    "go",
                    "gomod",
                    "gosum",
                    "gowork",
                    "html",
                    "javascript",
                    "jsdoc",
                    "lua",
                    "nix",
                    "regex",
                    "sql",
                    "templ",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "yaml",
                },

                -- Autoinstall languages that are not installed
                auto_install = false,
                -- Install languages synchronously (only applied to `ensure_installed`)
                sync_install = false,
                -- List of parsers to ignore installing
                ignore_install = {},
                -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
                modules = {},
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<c-space>",
                        node_incremental = "<c-space>",
                        scope_incremental = "<c-s>",
                        node_decremental = "<M-space>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>]"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>["] = "@parameter.inner",
                        },
                    },
                },
            })

            local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
            ---@diagnostic disable-next-line: inject-field
            parser_config.hyperscript = {
                install_info = {
                    url = "https://github.com/mbaraa/tree-sitter-hyperscript.git",
                    files = { "src/parser.c" },
                    branch = "main",
                },
                filetype = "hyperscript",
            }

            vim.treesitter.language.register("hyperscript", "hyperscript")

            ---@diagnostic disable-next-line: inject-field
            parser_config.openscad = {
                install_info = {
                    url = "https://github.com/bollian/tree-sitter-openscad.git",
                    files = { "src/parser.c" },
                    branch = "master",
                },
                filetype = "openscad",
            }

            vim.treesitter.language.register("openscad", "openscad")

            vim.api.nvim_set_hl(0, "@tag.attribute.html", { link = "Type" })
            vim.api.nvim_set_hl(0, "@tag.attribute.templ", { link = "Type" })
            vim.api.nvim_set_hl(0, "@tag.attribute.tsx", { link = "Type" })
            vim.api.nvim_set_hl(0, "@tag.attribute.typescriptreact", { link = "Type" })
        end, 0)
    end,
}
