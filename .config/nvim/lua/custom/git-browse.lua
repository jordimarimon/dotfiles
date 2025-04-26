-- Based on:
-- - https://github.com/Almo7aya/openingh.nvim
-- - https://github.com/folke/snacks.nvim/blob/main/docs/gitbrowse.md

local String = require("custom.string")
local Url = require("custom.url")
local M = {}

local remote_patterns = {
    { "^(https?://.*)%.git$",               "%1" },
    { "^git@(.+):(.+)%.git$",               "https://%1/%2" },
    { "^git@(.+):(.+)$",                    "https://%1/%2" },
    { "^git@(.+)/(.+)$",                    "https://%1/%2" },
    { "^org%-%d+@(.+):(.+)%.git$",          "https://%1/%2" },
    { "^ssh://git@(.*)$",                   "https://%1" },
    { "^ssh://([^:/]+)(:%d+)/(.*)$",        "https://%1/%3" },
    { "^ssh://([^/]+)/(.*)$",               "https://%1/%2" },
    { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
    { "^https://%w*@(.*)",                  "https://%1" },
    { "^git@(.*)",                          "https://%1" },
    { ":%d+",                               "" },
    { "%.git$",                             "" },
}

local url_patterns = {
    ["github%.com"] = {
        branch = "/tree/{branch}",
        branch_permalink = "/blob/{commit}",
        file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
        permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
        commit = "/commit/{commit}",
    },
    ["gitlab%.com"] = {
        branch = "/-/tree/{branch}",
        branch_permalink = "/-/blob/{commit}",
        file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
        permalink = "/-/blob/{commit}/{file}#L{line_start}-L{line_end}",
        commit = "/-/commit/{commit}",
    },
    ["bitbucket%.org"] = {
        branch = "/src/{branch}",
        branch_permalink = "/src/{commit}",
        file = "/src/{branch}/{file}#lines-{line_start}:{line_end}",
        permalink = "/src/{commit}/{file}#lines-{line_start}:{line_end}",
        commit = "/commits/{commit}",
    },
    ["git.sr.ht"] = {
        branch = "/tree/{branch}",
        branch_permalink = "/tree/{commit}",
        file = "/tree/{branch}/item/{file}",
        permalink = "/tree/{commit}/item/{file}#L{line_start}",
        commit = "/commit/{commit}",
    },
}

local priority = {
    BRANCH = 1,
    COMMIT = 2,
}

local state = {
    priority = priority.BRANCH,
}

-- get the active buf relative file path form the .git
local function get_relative_file_path()
    local absolute_file_path = vim.api.nvim_buf_get_name(0)
    local git_path = vim.fn.system("git rev-parse --show-toplevel")
    local relative_file_path_components = String.split(string.sub(absolute_file_path, git_path:len() + 1), "/")
    local encoded_components = {}

    for i, path_component in pairs(relative_file_path_components) do
        table.insert(encoded_components, i, Url.encode(path_component))
    end

    return table.concat(encoded_components, "/")
end

-- Get the current working branch
--- @return string
local function get_branch()
    return String.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))
end

-- Get the commit hash of the most recent commit
--- @param revision string|nil
--- @return string
local function get_commit_hash(revision)
    local rev = revision or "HEAD"
    return String.trim(vim.fn.system(("git rev-parse %s"):format(rev)))
end

--- @return string|nil
local function get_repo()
    -- Get the remote name
    local remote_name = String.trim(vim.fn.system("git config remote.pushDefault"))
    if not remote_name or remote_name == "" then
        remote_name = "origin"
    end

    -- Get the remote url
    local remote_url = String.trim(vim.fn.system("git config --get remote." .. remote_name .. ".url"))
    if not remote_url or remote_url == "" then
        vim.notify("No remote URL was found.", vim.log.levels.ERROR)
        return nil
    end

    local url = remote_url
    for _, pattern in ipairs(remote_patterns) do
        url = url:gsub(pattern[1], pattern[2]) --[[@as string]]
    end

    return (url:find("https://") == 1 and url) or ("https://%s"):format(url)
end

local function get_url(repo, fields)
    fields.line_start = fields.line_start or 1
    fields.line_end = fields.line_end or 1
    fields.branch = (fields.branch and Url.encode(fields.branch)) or ""
    fields.commit = (fields.commit and Url.encode(fields.commit)) or ""

    -- Bitbucket does not support branches with "/" in the name even when encoded.
    -- They use a query parameter "at={branch}" with a permalink instead.
    local has_slash_in_branch = fields.branch:find("/")

    for remote, patterns in pairs(url_patterns) do
        if repo:find(remote) then
            local pattern = nil

            if fields.file ~= nil and fields.file ~= "" then
                if state.priority == priority.BRANCH and has_slash_in_branch ~= nil then
                    pattern = patterns["file"]
                else
                    pattern = patterns["permalink"]
                end
            elseif fields.branch ~= "" then
                if state.priority == priority.BRANCH and has_slash_in_branch ~= nil then
                    pattern = patterns["branch"]
                else
                    pattern = patterns["branch_permalink"]
                end
            else
                pattern = patterns["commit"]
            end

            return repo .. pattern:gsub("(%b{})", function(key)
                return tostring(fields[key:sub(2, -2)] or key)
            end)
        end
    end

    return repo
end

function M.open_repo()
    local repo = get_repo()

    if not repo then
        return
    end

    local branch = get_branch()
    local commit = get_commit_hash()
    local url = get_url(repo, { branch = branch, commit = commit })

    vim.ui.open(url)

    vim.notify("Remote repository opened!", vim.log.levels.INFO)
end

--- @param revision string|nil
function M.open_commit(revision)
    local repo = get_repo()

    if not repo then
        return
    end

    local commit = get_commit_hash(revision)
    local url = get_url(repo, { commit = commit })

    vim.ui.open(url)

    vim.notify("Commit opened!", vim.log.levels.INFO)
end

--- @param line_start? integer
--- @param line_end? integer
function M.open_repo_file(line_start, line_end)
    if line_start > line_end then
        line_start, line_end = line_end, line_start
    end

    local file = get_relative_file_path()
    local repo = get_repo()

    if not repo then
        return
    end

    local branch = get_branch()
    local commit = get_commit_hash()
    local url = get_url(repo, {
        branch = branch,
        commit = commit,
        file = file,
        line_start = line_start,
        line_end = line_end,
    })

    vim.ui.open(url)

    vim.notify("File opened in remote repository!", vim.log.levels.INFO)
end

-- When the command executed with bang `!`,
-- prioritizes commit rather than branch.
--- @param bang boolean
function M.update_priority(bang)
    if bang then
        state.priority = priority.COMMIT
    else
        state.priority = priority.BRANCH
    end
end

return M
