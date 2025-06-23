return {
    {
        "williamboman/mason.nvim",
        config = function()
            -- setup mason with default properties
            require("mason").setup()
        end
    },
    -- mason lsp config utilizes mason to automatically ensure lsp servers you want installed are installed
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            -- ensure that we have lua language server, typescript launguage server, java language server, and java test language server are installed
            require("mason-lspconfig").setup({
                 ensure_installed = {
                "lua_ls",      -- lua
                "ts_ls",    -- typescript & javascript
                "jdtls",       -- java
                "html",        -- html
                "cssls",       -- css
                "emmet_ls",    -- emmet for html/css auto-expansion
                "eslint",      -- eslint for linting js/ts
                "tailwindcss", -- tailwind css
                "jsonls",      -- json
                "pyright"
                },
                automatic_installation = true,
            })
        end
    },
    -- mason nvim dap utilizes mason to automatically ensure debug adapters you want installed are installed, mason-lspconfig will not automatically install debug adapters for us
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            -- ensure the java debug adapter is installed
            require("mason-nvim-dap").setup({
                ensure_installed = { "java-debug-adapter", "java-test" }
            })
        end
    },
    -- utility plugin for configuring the java language server for us
    {
        "mfussenegger/nvim-jdtls",
        dependencies = {
            "mfussenegger/nvim-dap",
        }
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- get access to the lspconfig plugins functions
            local lspconfig = require("lspconfig")

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- setup the lua language server
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })

            lspconfig.html.setup({
                capabilities = capabilities,
                filetypes = { "html" }
            })


            -- setup the typescript language server
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
                filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            })

            lspconfig.jdtls.setup({
                capabilities = require('cmp_nvim_lsp').default_capabilities(), -- improved lsp completion
                autostart = true,
                root_dir = lspconfig.util.root_pattern("pom.xml", "gradle.build", ".git"), -- detect project root
                on_attach = function(client, bufnr)
                    -- auto-format & organize imports on save (only if available)
                    vim.api.nvim_create_autocmd("bufwritepre", {
                        buffer = bufnr,
                        callback = function()
                            -- get available code actions
                            local params = { context = { only = { "source.organizeimports" } }, range = nil }
                            vim.lsp.buf_request(bufnr, "textdocument/codeaction", params, function(err, actions)
                                if not err and actions and #actions > 0 then
                                    vim.lsp.buf.code_action({ context = { only = { "source.organizeimports" } }, apply = true })
                                end
                            end)

                            -- format the code
                            vim.lsp.buf.format()
                        end,
                    })
                end,
            })

            lspconfig.pyright.setup({
                on_attach = function (client, bufnr)
                 local opts = { buffer = bufnr, noremap = true, silent = true }
                 vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts);
                end,
                capabilities = capabilities,
                filetypes = { "python" },
                settings = {
                    python = {
                        analysis = {
                            autosearchpaths = true,
                            diagnosticmode = "openfilesonly", -- or "workspace"
                            uselibrarycodefortypes = true,
                        }
                    }
                }
            })

            lspconfig.dartls.setup({
              capabilities = capabilities,
              cmd = { "dart", "language-server", "--protocol=lsp" },
              filetypes = { "dart" },
              root_dir = lspconfig.util.root_pattern("pubspec.yaml"),
              settings = {
                dart = {
                  analysisexcludedfolders = { "**/build/**", "**/.dart_tool/**" },
                  completefunctioncalls = true,
                  showtodos = true,
                }
              }
            })

            -- set vim motion for <space> + c + h to show code documentation about the code the cursor is currently over if available
            vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[c]ode [h]over documentation" })
            -- set vim motion for <space> + c + d to go where the code/variable under the cursor was defined
            vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[c]ode goto [d]efinition" })
            -- set vim motion for <space> + c + a for display code action suggestions for code diagnostics in both normal and visual mode
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[c]ode [a]ctions" })
            -- set vim motion for <space> + c + r to display references to the code under the cursor
            vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, { desc = "[c]ode goto [r]eferences" })
            -- set vim motion for <space> + c + i to display implementations to the code under the cursor
            vim.keymap.set("n", "<leader>ci", require("telescope.builtin").lsp_implementations, { desc = "[c]ode goto [i]mplementations" })
            -- set a vim motion for <space> + c + <shift>r to smartly rename the code under the cursor
            vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "[c]ode [r]ename" })
            -- set a vim motion for <space> + c + <shift>d to go to where the code/object was declared in the project (class file)
            vim.keymap.set("n", "<leader>cd", vim.lsp.buf.declaration, { desc = "[c]ode goto [d]eclaration" })
        end
    }
}
