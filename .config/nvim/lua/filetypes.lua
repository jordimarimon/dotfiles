vim.filetype.add({
    extension = {
        h = "c",
    },
})

vim.filetype.add({
    pattern = {
        [".*%.component%.html"] = "htmlangular",
    },
})

vim.filetype.add({
    extension = {
        env = "dotenv",
    },
    filename = {
        [".env"] = "dotenv",
    },
    pattern = {
        ["%.env%.[%w_.-]+"] = "dotenv",
    },
})
