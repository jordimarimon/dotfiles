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
