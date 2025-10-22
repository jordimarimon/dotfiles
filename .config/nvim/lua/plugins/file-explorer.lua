-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
    local dir = require("oil").get_current_dir()
    if dir then
        return vim.fn.fnamemodify(dir, ":~")
    else
        -- If there is no current directory (e.g. over ssh), just show the buffer name
        return vim.api.nvim_buf_get_name(0)
    end
end

-- https://github.com/stevearc/oil.nvim
return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local detail = false

        require("oil").setup({
            keymaps = {
                ["gd"] = {
                    desc = "Toggle file detail view",
                    callback = function()
                        detail = not detail
                        if detail then
                            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
                        else
                            require("oil").set_columns({ "icon" })
                        end
                    end,
                },
            },
            win_options = {
                winbar = "%!v:lua.get_oil_winbar()",
            },
            float = {
                border = "single"
            },
            confirmation = {
                border = "single"
            },
            progress = {
                border = "single"
            },
        })
    end
}
