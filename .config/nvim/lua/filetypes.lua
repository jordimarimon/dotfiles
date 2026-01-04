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
