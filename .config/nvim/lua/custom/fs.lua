local M = {}

-- There is also "vim.api.nvim_buf_get_name(0)" but it doesn't
-- follow symlinks and it includes the file name
--- @return string|nil
function M.get_current_buffer_dir()
    -- ":h ::h" and ":h ::p"
    local path = vim.fn.expand("%:p:h")

    if vim.startswith(path, "oil://") then
        path = string.sub(path, 7)
    end

    return vim.uv.fs_realpath(path)
end

--- @param files table
--- @return string?
function M.root_files(files)
    return vim.fs.root(0, files)
end

---Join path segments
---@return string
M.join_paths = function(...)
    local parts = { ... }
    return table.concat(parts, "/")
end

---Returns true if the path is absolute, false otherwise
---@return boolean
M.is_absolute_path = function(path)
    if path:match("^/") then
        return true
    end

    return false
end

---Either returns the absolute path if the path is already absolute or
---joins the path with the current buffer directory
---@param path string
M.get_file_path = function(path)
    local ex_path = vim.fn.expand(path, true)
    path = ex_path ~= "" and ex_path or path

    if M.is_absolute_path(path) then
        return path
    end

    if path:sub(1, 2) == "./" then
        path = path:sub(3)
    end

    return M.join_paths(M.get_current_buffer_dir(), path)
end

-- Writes string to file
---@param filename string
---@param content string
---@param append boolean|nil
---@param binary boolean|nil
---@return boolean
M.write_file = function(filename, content, append, binary)
    local file, mode

    mode = append and "a" or "w"
    mode = binary and mode .. "b" or mode

    filename = M.get_file_path(filename)

    file = io.open(filename, mode)
    if not file then
        return false
    end

    file:write(content)
    file:close()

    return true
end

-- Delete a file
--- @param filename string
--- @return boolean
M.delete_file = function(filename)
    return vim.fn.delete(filename) ~= 0
end

-- Check if a file exists
--- @param filename string
--- @return boolean
M.file_exists = function(filename)
    return vim.fn.filereadable(filename) == 1
end

---Read a file with path absolute or relative to buffer dir
---@param filename string path
---@param is_binary boolean|nil
---@return string|nil
M.read_file = function(filename, is_binary)
    if not filename then
        return
    end
    local read_mode = is_binary and "rb" or "r"

    filename = M.get_file_path(filename)
    local file = io.open(filename, read_mode)

    if not file then
        return
    end

    local content = file:read("*a")
    if not content then
        return
    end

    content = is_binary and content or content:gsub("\r\n", "\n")
    file:close()

    return content
end

return M
