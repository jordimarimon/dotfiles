-- set the colorscheme
vim.cmd.colorscheme("light")

-- define options
require("options")
require("tabs")
require("filetypes")

-- define plugins
require("plugins")
require("lazy").setup({
    { import = "plugins.file-picker" },
    { import = "plugins.syntax" },
    { import = "plugins.completion" },
    { import = "plugins.git" },
    { import = "plugins.mini" },
    { import = "plugins.markdown" },
    { import = "plugins.database" },
    { import = "plugins.file-explorer" },
    { import = "plugins.undotree" },
    { import = "plugins.format" },
    { import = "plugins.package-manager" },
    { import = "plugins.progress" },
}, {
    ui = { border = "single" },
    install = {
        -- Do not automatically install on startup.
        missing = false,
    },
    -- Don't bother me when tweaking plugins.
    change_detection = { notify = false },
    -- None of my plugins use luarocks so disable this.
    rocks = {
        enabled = false,
    },
    performance = {
        rtp = {
            -- Stuff I don't use.
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- define keymaps
require("keymaps")

-- define autocommands
require("autocmds")

-- enable lsps
require("lsp")

-- See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
