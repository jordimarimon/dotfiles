-- Based on: https://github.com/Almo7aya/openingh.nvim
-- There is also GBrowse of fugitive

-- TODO: Look at snacks implementation:
--       https://github.com/folke/snacks.nvim/blob/main/docs/gitbrowse.md

local String = require("custom.string")
local M = {}

local priority = {
    BRANCH = 1,
    COMMIT = 2,
}

local state = {
    priority = priority.BRANCH,
}

-- get the active buf relative file path form the .git
local function get_current_relative_file_path()
  local absolute_file_path = vim.api.nvim_buf_get_name(0)
  local git_path = vim.fn.system("git rev-parse --show-toplevel")
  local relative_file_path_components = String.split(string.sub(absolute_file_path, git_path:len() + 1), "/")
  local encoded_components = {}

  for i, path_component in pairs(relative_file_path_components) do
    table.insert(encoded_components, i, String.encode_uri_component(path_component))
  end

  return "/" .. table.concat(encoded_components, "/")
end

-- Get the current working branch
--- @return string
local function get_current_branch()
  return String.encode_uri_component(String.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD")))
end

-- Get the commit hash of the most recent commit
--- @return string
local function get_current_commit_hash()
  return String.encode_uri_component(String.trim(vim.fn.system("git rev-parse HEAD")))
end

--- @param url string
local function parse_remote(url)
  -- The URL can be of type:
  -- http://domain/user_or_org/reponame
  -- https://domain/user_or_org/reponame
  -- https://domain/user_or_org/group/reponame
  -- git@domain:user_or_org/reponame.git
  -- ssh://git@domain/user_or_org/reponame.git
  -- ssh://org-e2345@domain/org/reponame.git
  local matches = { string.find(url, "^.+[@/]([%w%.]+%.%w+)[/:](.+)/(%S+)") }

  if matches[1] == nil then
    return nil
  end

  local _, _, host, user_or_org, repo_name = unpack(matches)

  return {
      host = host,
      user_or_org = user_or_org,
      reponame = string.gsub(repo_name, ".git", ""),
  }
end

--- @return string|nil
local function get_repo_url()
    -- Get the remote
    local remote = String.trim(vim.fn.system("git config remote.pushDefault"))
    if not remote or remote == "" then
        remote = "origin"
    end

    -- Get the repository url
    local git_url = String.trim(vim.fn.system("git config --get remote." .. remote .. ".url"))
    if not git_url or git_url == "" then
        vim.notify("No repository URL was found.", vim.log.levels.ERROR)
        return nil
    end

    local parsed_url = parse_remote(git_url)
    if not parsed_url then
        vim.notify("Can't parse repository URL.", vim.log.levels.ERROR)
        return nil
    end

    return string.format("https://%s/%s/%s", parsed_url.host, parsed_url.user_or_org, parsed_url.reponame)
end

function M.open_repo()
    local repo_url = get_repo_url()

    if not repo_url then
        return
    end

    local url = ""
    if state.priority == priority.BRANCH then
        url = repo_url .. "/src/" .. get_current_branch()
    else
        url = repo_url .. "/src/" .. get_current_commit_hash()
    end

    vim.ui.open(url)

    vim.notify("Remote repository opened!", vim.log.levels.INFO)
end

--- @param line_start? integer
--- @param line_end? integer
function M.open_repo_file(line_start, line_end)
    -- Get the absolute path of the buffer directory and escape any
    -- square bracket in the path.
    -- Square brackets have a special meaning in lua patterns.
    local file_path = get_current_relative_file_path()
    local repo_url = get_repo_url()

    if not repo_url then
        return
    end

    local url = ""
    if state.priority == priority.BRANCH then
        url = repo_url .. "/src/" .. get_current_branch() .. file_path
    else
        url = repo_url .. "/src/" .. get_current_commit_hash() .. file_path
    end

    if line_start ~= 1 or line_end ~= 1 then
        url = url .. "#lines-" .. line_start

        if line_end ~= line_start then
            url = url .. ":" .. line_end
        end
    end

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
