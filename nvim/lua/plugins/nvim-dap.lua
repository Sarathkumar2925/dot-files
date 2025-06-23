return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- UI plugins to enhance debugging experience
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        -- Mason plugin to manage debugger installations
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
        -- Load required plugins
        local dap = require("dap")
        local dapui = require("dapui")
        local mason_dap = require("mason-nvim-dap")

        -- Setup DAP UI
        dapui.setup()

        -- Automatically open/close UI on debugger start/exit
        dap.listeners.before.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- Mason DAP setup to ensure debuggers are installed
        mason_dap.setup({
            ensure_installed = { "java" }, -- Ensures the Java debugger is installed
            automatic_installation = true,
        })

        -- Configure DAP for Java (Spring Boot)
        dap.configurations.java = {
            {
                type = "java",
                request = "launch",
                name = "Debug Spring Boot App",
                mainClass = function()
                     -- Automatically use the file under the cursor
                    local current_file = vim.fn.expand("%:p")
                    return vim.fn.input("Main Class (default: " .. current_file .. "): ", current_file, "file")
                end,
                projectRoot = "${workspaceFolder}",
                cwd = "${workspaceFolder}",
                console = "integratedTerminal",
                vmArgs = "-Dspring.profiles.active=debug", -- Spring-specific configuration
                args = function()
                    return vim.split(vim.fn.input("Program Arguments: "), " ")
                end,
            },
        }

        dap.adapters.python = {
                    type = "executable",
                    command = "python",
                    args = { "-m", "debugpy.adapter" }
                }

        dap.configurations.python = {
            {
                type = "python",
                request = "launch",
                name = "Launch file",
                program = "${file}", -- Run current file
                pythonPath = function()
                    return "python"  -- Adjust if using virtualenv
                end
            }
        }

        -- Keybindings for debugging
        vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "[D]ebug [T]oggle Breakpoint" })
        vim.keymap.set("n", "<leader>ds", dap.continue, { desc = "[D]ebug [S]tart/Continue" })
        vim.keymap.set("n", "<leader>dc", dapui.close, { desc = "[D]ebug [C]lose" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug Step [I]n" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug Step [O]ver" })
        vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[D]ebug [R]EPL" })

        -- Keybinding to set conditional breakpoints
        vim.keymap.set("n", "<leader>db", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, { desc = "[D]ebug Set Conditional [B]reakpoint" })
    end,
}
