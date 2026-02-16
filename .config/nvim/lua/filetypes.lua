vim.filetype.add({
    extension = {
        h = "c",
    },
})

vim.filetype.add({
    pattern = {
        [".*%.html"] = "htmlangular",
    },
})

vim.filetype.add({
    pattern = {
        [".*%.neon"] = "yaml",
    },
})

vim.filetype.add({
    filename = {
        ["my.cnf"] = "toml",
    },
})

vim.filetype.add({
    extension = {
        env = "bash",
    },
    filename = {
        [".env"] = "bash",
    },
    pattern = {
        ["%.env%.[%w_.-]+"] = "bash",
    },
})
