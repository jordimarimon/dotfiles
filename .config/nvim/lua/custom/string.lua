local M = {}

-- Remove leading and trailing whitespace from the output of git commands
--- @param value string
--- @return string
function M.trim(value)
    return string.match(value, "^%s*(.-)%s*$")
end

--- @param value string
--- @param sep string
function M.split(value, sep)
    local result = {}
    local reg = value.format("([^%s]+)", sep)

    for mem in value.gmatch(value, reg) do
        table.insert(result, mem)
    end

    return result
end

-- url encode
-- see: https://datatracker.ietf.org/doc/html/rfc3986#section-2.3
--- @param url string|number
--- @return string
function M.encode_uri_component(url)
    url = tostring(url)

    return (url:gsub("[^%w_~%.%-]", function(c)
        return url.format("%%%02X", url.byte(c))
    end))
end

return M
