function _G.tablabel()
    local labels = {}
    local selected = vim.fn.tabpagenr()
    local len = vim.fn.tabpagenr("$")

    for i = 1, len do
        if i == selected then
            table.insert(labels, "%#TabLineSel#" .. " " .. " " .. i .. " ")
        else
            table.insert(labels, "%#TabLine#" .. " " .. " " .. i .. " ")
        end
    end

    return table.concat(labels)
end

vim.o.tabline = "%!v:lua._G.tablabel()"

