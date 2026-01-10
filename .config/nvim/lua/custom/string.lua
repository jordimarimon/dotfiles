local M = {}

-- Remove leading and trailing whitespace from the output of git commands
--- @param value string
--- @return string
function M.trim(value)
    return string.match(value, "^%s*(.-)%s*$")
end

--- @param value string
--- @param sep string
--- @return table
function M.split(value, sep)
    local result = {}
    local reg = value.format("([^%s]+)", sep)

    for mem in value.gmatch(value, reg) do
        table.insert(result, mem)
    end

    return result
end

--- @param c string
--- @return string
function M.char_to_hex(c)
    return string.format("%%%02X", string.byte(c))
end

--- @param x string
--- @return string
function M.hex_to_char(x)
    return string.char(tonumber(x, 16))
end

--- @param value string
--- @return string
function M.escape(value)
    return value:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Generates a random string of "n" symbols
---@param n integer
---@return string
function M.random_word(n)
    local pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" .. "abcdefghijklmnopqrstuvwxyz" .. "0123456789"
    local pool_len = pool:len()
    local word = {}

    for i = 1, n do
        local index = math.random(1, pool_len)
        word[i] = pool:sub(index, index)
    end

    return table.concat(word)
end

return M
