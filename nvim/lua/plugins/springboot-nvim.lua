return {
    "elmcgill/springboot-nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-jdtls"
    },
    config = function()
        local springboot_nvim = require("springboot-nvim")
        local job_id = nil
        local output_bufnr = nil
        local output_win_id = nil
        local build_output_bufnr = nil
        local build_output_win_id = nil

        -- Detect if the project uses Gradle or Maven and which framework
        local function detect_project_config()
            local build_tool
            local framework
            -- Detect build tool
            if vim.fn.filereadable("gradlew") == 1 or vim.fn.filereadable("build.gradle") == 1 then
                build_tool = "gradle"
            elseif vim.fn.filereadable("pom.xml") == 1 then
                build_tool = "maven"
            end

            -- Detect framework by checking dependencies
            if build_tool == "gradle" then
                local build_file = io.open("build.gradle", "r")
                if build_file then
                    local content = build_file:read("*all")
                    build_file:close()
                    if content:match("spring%-boot") then
                        framework = "spring"
                    elseif content:match("quarkus") then
                        framework = "quarkus"
                    end
                end
            elseif build_tool == "maven" then
                local pom_file = io.open("pom.xml", "r")
                if pom_file then
                    local content = pom_file:read("*all")
                    pom_file:close()
                    if content:match("spring%-boot") then
                        framework = "spring"
                    elseif content:match("quarkus") then
                        framework = "quarkus"
                    end
                end
            end

            return build_tool, framework
        end

        -- Function to get the correct build and run commands
        local function get_build_commands()
            local build_tool, framework = detect_project_config()
            if build_tool == "gradle" then
                if framework == "spring" then
                    return "./gradlew build", "./gradlew bootRun"
                elseif framework == "quarkus" then
                    return "./gradlew build", "./gradlew quarkusDev"
                end
            elseif build_tool == "maven" then
                if framework == "spring" then
                    return "mvn clean install", "mvn spring-boot:run"
                elseif framework == "quarkus" then
                    return "mvn clean install", "mvn quarkus:dev"
                end
            end

            return nil, nil
        end

        -- Rest of the functions remain mostly the same, just update the messages
        local function open_build_output_buffer()
            if build_output_bufnr and vim.api.nvim_buf_is_valid(build_output_bufnr) then
                return build_output_bufnr, build_output_win_id
            end

            vim.cmd("botright new")
            vim.cmd("resize 10")
            vim.cmd("setlocal nobuflisted buftype=nofile")

            build_output_win_id = vim.api.nvim_get_current_win()
            build_output_bufnr = vim.api.nvim_get_current_buf()

            return build_output_bufnr, build_output_win_id
        end

        local function build_and_run()
            local build_cmd, run_cmd = get_build_commands()
            local _, framework = detect_project_config()

            if not build_cmd or not run_cmd then
                print("❌ No supported framework detected (Spring Boot or Quarkus).")
                return
            end

            local buf, win = open_build_output_buffer()
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "🔄 Building project..." })

            local output_lines = {}

            vim.fn.jobstart(build_cmd, {
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = function(_, data)
                    if data then
                        for _, line in ipairs(data) do
                            table.insert(output_lines, line)
                        end
                    end
                end,
                on_stderr = function(_, data)
                    if data then
                        for _, line in ipairs(data) do
                            table.insert(output_lines, line)
                        end
                    end
                end,
                on_exit = function(_, exit_code)
                    if exit_code == 0 then
                        print("✅ Build successful! Running " .. (framework == "spring" and "Spring Boot" or "Quarkus") .. "...")

                        if build_output_win_id and vim.api.nvim_win_is_valid(build_output_win_id) then
                            vim.api.nvim_win_close(build_output_win_id, true)
                        end
                        if build_output_bufnr and vim.api.nvim_buf_is_valid(build_output_bufnr) then
                            vim.api.nvim_buf_delete(build_output_bufnr, { force = true })
                        end

                        local current_win = vim.api.nvim_get_current_win()
                        vim.cmd("botright new")
                        vim.cmd("resize 15")
                        vim.cmd("setlocal nobuflisted")

                        output_win_id = vim.api.nvim_get_current_win()
                        output_bufnr = vim.api.nvim_get_current_buf()

                        job_id = vim.fn.termopen(run_cmd, {
                            on_exit = function()
                                print("🛑 Application process exited.")
                                job_id = nil
                                if output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr) then
                                    vim.api.nvim_buf_delete(output_bufnr, { force = true })
                                    output_bufnr = nil
                                end
                                if output_win_id and vim.api.nvim_win_is_valid(output_win_id) then
                                    vim.api.nvim_win_close(output_win_id, true)
                                    output_win_id = nil
                                end
                            end
                        })

                        vim.b[output_bufnr].job_id = job_id
                        vim.cmd("setlocal scrolloff=0")
                        vim.cmd("normal! G")
                        vim.wo[output_win_id].scrolloff = 0
                        vim.wo[output_win_id].wrap = false
                        vim.api.nvim_set_current_win(current_win)
                    else
                        print("❌ Build failed. Check the output.")
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
                        vim.api.nvim_set_current_win(win)
                    end
                end
            })
        end

        local function stop_application()
            if job_id then
                vim.fn.jobstop(job_id)
                print("🛑 Application stopped.")
                job_id = nil
            end
            if output_bufnr and vim.api.nvim_buf_is_valid(output_bufnr) then
                vim.api.nvim_buf_delete(output_bufnr, { force = true })
                output_bufnr = nil
            end
            if output_win_id and vim.api.nvim_win_is_valid(output_win_id) then
                vim.api.nvim_win_close(output_win_id, true)
                output_win_id = nil
            end
        end

        -- Key mappings
        vim.keymap.set('n', '<leader>Jr', build_and_run, { desc = "[J]ava [R]un Application" })
        vim.keymap.set('n', '<leader>Js', stop_application, { desc = "[J]ava [S]top Application" })
        vim.keymap.set('n', '<leader>Jc', springboot_nvim.generate_class, { desc = "[J]ava Create [C]lass" })
        vim.keymap.set('n', '<leader>Ji', springboot_nvim.generate_interface, { desc = "[J]ava Create [I]nterface" })
        vim.keymap.set('n', '<leader>Je', springboot_nvim.generate_enum, { desc = "[J]ava Create [E]num" })

        springboot_nvim.setup({})
    end
}
