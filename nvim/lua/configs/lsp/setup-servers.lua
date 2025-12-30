local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local schemastore = require("schemastore")
local on_attach = require("configs.lsp.on-attach")
local filetypes = require("utils.filetypes")

-- Enable the following language servers
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.

--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    bashls = {},
    cssls = {},
    eslint = {},
    marksman = {},
    prismals = {},
    taplo = {},

    arduino_language_server = {
        cmd = {
            "arduino-language-server",
            "-cli-config",
            "$HOME/Library/Arduino15/arduino-cli.yaml",
            "-fqbn",
            "arduino:avr:uno",
        },
    },

    emmet_language_server = {
        filetypes = {
            filetypes.html,
            filetypes.htmx,
            filetypes.liquid,
            filetypes.markdown,
            filetypes.templ,
            filetypes.webc,
            filetypes.tsx,
            filetypes.jsx,
            filetypes.typescript,
            filetypes.javascript,
        },
    },

    gh_actions_ls = {
        cmd = { "gh-actions-language-server", "--stdio" },
        filetypes = { "yaml.github" },
        -- root_dir = vim.lsp.util.root_pattern(".github"),
        root_dir = function(bufnr, on_dir)
            if vim.fs.root(bufnr, ".github") then
                on_dir(vim.fn.getcwd())
            end
        end,
        single_file_support = true,
        capabilities = {
            workspace = {
                didChangeWorkspaceFolders = {
                    dynamicRegistration = true,
                },
            },
        },
    },

    ---@url https://github.com/golang/tools/tree/master/gopls/doc
    gopls = {
        cmd = { "gopls", "--remote=auto" },
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true,
                usePlaceholders = true,
                completeUnimported = true,
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                analyses = {
                    unreachable = true,
                    nilness = true,
                    ST1003 = true,
                    fieldalignment = true,
                    unusedvariable = true,
                    unusedParams = true,
                    useany = true,
                },
            },
        },
        filetypes = {
            filetypes.go,
            filetypes.gomod,
            filetypes.gotmpl,
            filetypes.gowork,
        },
    },

    golangci_lint_ls = {
        cmd = { "golangci-lint-langserver" },
        init_options = {
            command = {
                "golangci-lint",
                "run",
                "--output.json.path",
                "stdout",
                "--show-stats=false",
            },
        },
        filetypes = {
            filetypes.go,
            filetypes.gomod,
            filetypes.gotmpl,
            filetypes.gowork,
        },
    },

    html = {
        filetypes = {
            filetypes.html,
            filetypes.htmx,
            filetypes.liquid,
            filetypes.markdown,
            filetypes.templ,
            filetypes.webc,
        },
    },

    htmx = {
        filetypes = {
            filetypes.html,
            filetypes.htmx,
            filetypes.templ,
            filetypes.webc,
        },
    },

    jsonls = {
        settings = {
            json = {
                schemas = schemastore.json.schemas(),
                validate = { enable = true },
            },
        },
    },

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
        },
    },

    rust_analyzer = {
        cargo = { allFeatures = true },
        files = { excludeDirs = { ".git" } },
        diagnostics = { enable = true },
        cache = { warmup = true },
        buildScripts = { enable = true, rebuildOnSave = false },
    },

    sqls = {
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            require("sqls").on_attach(client, bufnr)
            on_attach(client, bufnr)
        end,
    },

    tailwindcss = {
        filetypes = {
            filetypes.html,
            filetypes.htmx,
            filetypes.liquid,
            filetypes.markdown,
            filetypes.templ,
            filetypes.tsx,
            filetypes.jsx,
            filetypes.typescript,
            filetypes.javascript,
        },
        init_options = { includeLanguages = { templ = "html" } },
    },

    templ = {
        cmd = { "templ", "lsp", "-log", vim.fn.stdpath("cache") .. "/templ.log" },
        filetypes = { filetypes.templ },
    },

    ts_ls = {
        implicitProjectConfiguration = {
            checkJs = true,
        },
    },

    yamlls = {
        settings = {
            yaml = {
                schemaStore = {
                    -- You must disable built-in schemaStore support if you want to use
                    -- this plugin and its advanced options like `ignore`.
                    enable = false,
                    -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                    url = "",
                },
                schemas = schemastore.yaml.schemas(),
            },
        },
    },
}

-- Servers not available through the Mason Registry but supported by lspconfig.
-- Most likely manually installed on the system.
local external_servers = {
    nixd = {}, -- https://github.com/nix-community/nixd/blob/main/nixd/docs/editor-setup.md

    clangd = {
        cmd = {
            "clangd",
            "--query-driver=**",
            "--clang-tidy",
        },
    },
}

local mason_tools_installs = vim.tbl_extend("keep", {}, vim.tbl_keys(servers))

local function setup_handlers(capabilities)
    local srv = vim.tbl_extend("keep", servers, external_servers)

    -- Add specific handlers for servers that need custom setup
    for server_name, server_config in next, srv, nil do
        vim.lsp.config(server_name, {
            capabilities = capabilities,
            on_attach = server_config.on_attach or on_attach,
            cmd = server_config.cmd,
            settings = server_config.settings,
            filetypes = server_config.filetypes,
            init_options = server_config.init_options,
            single_file_support = true,
        })

        vim.lsp.enable({ server_name })
    end
end

return function()
    -- mason-lspconfig requires that these setup functions are called in this order
    -- before setting up the servers.
    mason.setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

    -- Ensure document symbol capability is enabled (needed for outline.nvim)
    capabilities.textDocument.documentSymbol = {
        dynamicRegistration = false,
        symbolKind = {
            valueSet = (function()
                local values = {}
                for i = 1, 26 do
                    table.insert(values, i)
                end
                return values
            end)(),
        },
        hierarchicalDocumentSymbolSupport = true,
    }

    mason_lspconfig.setup({
        ensure_installed = mason_tools_installs,
        automatic_installation = false,
        automatic_enable = false,
    })

    -- Making sure `.h` files are declared as C files and not C++
    vim.cmd("let g:c_syntax_for_h = 1")
    -- Setting default SQL dialect as PostgreSQL
    vim.cmd("let g:sql_type_default = 'pgsql'")

    setup_handlers(capabilities)
end
