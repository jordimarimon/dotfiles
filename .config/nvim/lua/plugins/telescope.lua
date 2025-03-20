-- Fuzzy Finder (files, lsp, etc)
return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {
            "nvim-lua/plenary.nvim",
            lazy = true,
        },

        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
                return vim.fn.executable "make" == 1
            end,
        },

        { "nvim-telescope/telescope-ui-select.nvim" },

        {
            "nvim-tree/nvim-web-devicons",
            enabled = true,
        },
    },
    config = function()
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local scan = require("plenary.scandir")
        local path = require("plenary.path")
        local os_sep = path.path.sep
        local pickers = require("telescope.pickers")
        local action_set = require("telescope.actions.set")
        local conf = require("telescope.config").values
        local finders = require("telescope.finders")
        local make_entry = require("telescope.make_entry")

        local picker_state = {
            ---@type "grep"|"files"
            mode = "grep",
            ---@type nil|string
            extension = nil,
            ---@type nil|string[]
            directories = nil,
        }

        local custom_live_grep = function(current_input)
            builtin.live_grep({
                additional_args = picker_state.extension and function()
                    return { "-g", "**" .. os_sep .. "*." .. picker_state.extension }
                end,
                search_dirs = picker_state.directories,
                default_text = current_input,
            })
        end

        local custom_find_files = function(current_input)
            builtin.find_files({
                search_dirs = picker_state.directories,
                default_text = current_input,
            })
        end

        local set_extensions = function(prompt_bufnr)
            local current_input = action_state.get_current_line()

            vim.ui.input({ prompt = "*." }, function(input)
                if input == nil then
                    return
                end

                picker_state.extension = input

                actions.close(prompt_bufnr)

                custom_live_grep(current_input)
            end)
        end

        local set_directories = function(prompt_bufnr)
            local current_input = action_state.get_current_line()
            local data = {}

            scan.scan_dir(vim.uv.cwd(), {
                hidden = true,
                only_dirs = true,
                respect_gitignore = true,
                on_insert = function(entry)
                    table.insert(data, entry .. os_sep)
                end,
            })

            table.insert(data, 1, "." .. os_sep)

            actions.close(prompt_bufnr)

            local picker_opts = {
                prompt_title = "Select Folders",
                finder = finders.new_table({ results = data, entry_maker = make_entry.gen_from_file({}) }),
                previewer = conf.file_previewer({}),
                sorter = conf.file_sorter({}),
                attach_mappings = function(bufnr)
                    action_set.select:replace(function()
                        local dirs = {}
                        local current_picker = action_state.get_current_picker(bufnr)
                        local selections = current_picker:get_multi_selection()

                        if vim.tbl_isempty(selections) then
                            table.insert(dirs, action_state.get_selected_entry().value)
                        else
                            for _, selection in ipairs(selections) do
                                table.insert(dirs, selection.value)
                            end
                        end

                        picker_state.directories = dirs

                        actions.close(bufnr)

                        if picker_state.mode == "grep" then
                            custom_live_grep(current_input)
                        else
                            custom_find_files(current_input)
                        end
                    end)

                    return true
                end,
            }

            pickers.new({}, picker_opts):find()
        end

        -- Telescope is a fuzzy finder that comes with a lot of different things that
        -- it can fuzzy find! It's more than just a "file finder", it can search
        -- many different aspects of Neovim, your workspace, LSP, and more!
        --
        -- The easiest way to use Telescope, is to start by doing something like:
        --  :Telescope help_tags
        --
        -- After running this command, a window will open up and you're able to
        -- type in the prompt window. You'll see a list of `help_tags` options and
        -- a corresponding preview of the help.

        -- Two important keymaps to use while in Telescope are:
        --  - Insert mode: <c-/>
        --  - Normal mode: ?
        --
        -- This opens a window that shows you all of the keymaps for the current
        -- Telescope picker. This is really useful to discover what Telescope can
        -- do as well as how to actually do it!

        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        require("telescope").setup({
            defaults = {
                -- TODO: Improve it using the suggestions in:
                -- https://github.com/nvim-telescope/telescope.nvim/issues/2014
                path_display = function(opts, file_path)
                    local tail = require("telescope.utils").path_tail(file_path)
                    return string.format("%s (%s)", tail, file_path), { { { 1, #tail }, "Constant" } }
                end,
                layout_strategy = "horizontal",
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                    height = 0.95,
                    mirror = false,
                },
            },
            pickers = {
                live_grep = {
                    mappings = {
                        i = {
                            ["<c-f>"] = set_extensions,
                            ["<c-l>"] = function(prompt_bufnr)
                                picker_state.mode = "grep"
                                set_directories(prompt_bufnr)
                            end,
                        },
                    },
                },
                find_files = {
                    mappings = {
                        i = {
                            ["<c-l>"] = function(prompt_bufnr)
                                picker_state.mode = "files"
                                set_directories(prompt_bufnr)
                            end,
                        },
                    },
                },
            },
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
                fzf = {},
            },
        })

        -- Enable Telescope extensions if they are installed
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")

        -- See `:help telescope.builtin`
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>si", function() builtin.find_files({ hidden = true, no_ignore = true }) end,
            { desc = "[S]earch [I]gnored files" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
        vim.keymap.set("n", "<leader>sm", builtin.marks, { desc = "[S]earch [M]arks" })
        vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search [G]it [C]ommits" })
        vim.keymap.set("n", "<leader>gf", builtin.git_bcommits, { desc = "Search [G]it commits for current [F]ile" })

        vim.keymap.set("n", "<leader><leader>", function()
            builtin.current_buffer_fuzzy_find(
                require("telescope.themes").get_dropdown({
                    winblend = 10,
                    previewer = false,
                })
            )
        end, { desc = "Fuzzily [S]earch in current [B]uffer" })

        vim.keymap.set("n", "<leader>so", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, { desc = "[S]earch in [O]pen Files" })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set("n", "<leader>sn", function()
            builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end, { desc = "[S]earch [N]eovim files" })

        -- Shortcut for searching plugins source files
        vim.keymap.set("n", "<leader>sp", function()
            builtin.find_files({
                cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
            })
        end, { desc = "[S]earch [P]lugin files" })
    end,
}
