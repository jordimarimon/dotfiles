-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
-- https://gist.github.com/ignisdesign/4323051
-- http://stackoverflow.com/questions/20282054/how-to-urldecode-a-request-uri-string-in-lua
-- https://github.com/stuartpb/tvtropes-lua/blob/master/urlencode.lua

local M = {}
local String = require("custom.string")

--- @param url string
--- @return string|nil
function M.encode(url)
    if url == nil then
        return
    end

    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w_~%.%-])", String.char_to_hex)
    url = url:gsub(" ", "+")

    return url
end

--- @param url string
--- @return string|nil
function M.decode(url)
    if url == nil then
        return
    end

    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", String.hex_to_char)

    return url
end

return M
