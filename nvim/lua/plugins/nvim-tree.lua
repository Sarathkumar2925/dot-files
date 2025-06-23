return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        vim.keymap.set('n', '<leader>e', "<cmd>NvimTreeToggle<CR>", {desc = "Toggle [E]xplorer"})
        require("nvim-tree").setup({
            hijack_netrw = true,
            auto_reload_on_write = true,
            sync_root_with_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
            renderer = {
                indent_markers = {
                    enable = true,  -- Show indentation lines
                },
                icons = {
                    show = {
                        folder_arrow = false,  -- Hide arrows if not needed
                    },
                },
            },
            actions = {
                open_file = {
                    resize_window = true,  -- Adjust window size when opening files
                },
            },
            filesystem_watchers = {
                enable = true,  -- Auto-update file changes
            },
            git = {
                enable = true,
                ignore = false,  -- Show ignored files
            },
            diagnostics = {
                enable = true,
            },

            -- Enable horizontal scrolling
            view = {
                side = 'right',
                adaptive_size = true,
            },
        })
    end
}
