-- Based on: https://github.com/jecaro/fugitive-difftool.nvim/tree/main
-- Usage: `:G! difftool --name-status {branch1}...{branch2}`

local M = {}
local String = require("custom.string")
local state = {
    branches = nil,
}

local function git_file_exists(obj)
    local job_id = vim.fn.jobstart({ "git", "cat-file", "-e", obj })
    local result = vim.fn.jobwait({ job_id })
    return #result == 1 and result[1] == 0
end

---@return string[]
function M.get_branches()
    if state.branches then
        return state.branches
    end

    local branches_cmd = vim.system(
        { "git", "branch", "--all", "--remotes", "--no-color" },
        { text = true }
    )

    local branches = String.split(branches_cmd:wait().stdout, "\n")

    for index, branch in ipairs(branches) do
        local branch_name, _ = String.trim(branch):gsub("%s%->.+$", "")
        branches[index] = branch_name
    end

    state.branches = branches

    return branches
end

---@param review_branch string
function M.review(review_branch)
    -- We assume that for reviewing a branch we want all commits reachable from
    -- that branch and not reachable from well known trunck branches
    local trunk_branches = { "main", "dev", "master", "next" }
    local branches = M.get_branches()
    local ignore_branches = {}

    for _, branch_name in ipairs(branches) do
        for _, trunk_branch in ipairs(trunk_branches) do
            if branch_name:find(trunk_branch, 1, true) ~= nil then
                table.insert(ignore_branches, branch_name)
            end
        end
    end

    local git_log_cmd = { "git", "log", "--pretty=format:'%h'", review_branch }
    for _, ignored_branch in ipairs(ignore_branches) do
        table.insert(git_log_cmd, "^" .. ignored_branch)
    end

    -- The last one is the oldest commit
    local commits_cmd = vim.system(git_log_cmd, { text = true }):wait()
    local commits = String.split(commits_cmd.stdout, "\n")
    for index, commit in ipairs(commits) do
        commits[index] = commit:gsub("'", "")
    end

    local first_commit = commits[#commits]

    -- Show commits in one tab (to be able to review them individually if necessary)
    vim.cmd("tabedit")
    vim.cmd("G log " .. table.concat(commits, " ") .. " ^" .. first_commit .. "~1")
    vim.cmd("only") -- make the current window the only one

    -- Show all changes made between all commits (for a global view)
    vim.cmd("tabedit")
    vim.cmd("G! difftool --name-status " .. first_commit .. "~1..." .. review_branch)
end

function M.diff()
    local winnr = vim.fn.winnr()
    local tabnr = vim.fn.tabpagenr()
    local all_windows = vim.fn.getwininfo()
    local windows_in_tabpage = {}
    local qf_has_focus = false

    for _, window in ipairs(all_windows) do
        if window.quickfix == 0 then
            if window.tabnr == tabnr then
                table.insert(windows_in_tabpage, window)
            end
        elseif window.winnr == winnr then
            qf_has_focus = true
        end
    end

    -- Get the current entry in the quickfix list
    local qf_idx = nil
    if not qf_has_focus then
        qf_idx = vim.fn.getqflist({ idx = 0 }).idx
    else
        qf_idx = vim.fn.line(".")
        vim.fn.setqflist({}, "a", { idx = qf_idx })
    end

    local qf_current = vim.fn.getqflist()[qf_idx]

    if qf_current == nil then
        vim.notify("There is no quickfix list", vim.log.levels.ERROR)
        return
    end

    -- Set focus to a random window and clear the others
    if #windows_in_tabpage ~= 0 then
        local new_focused = table.remove(windows_in_tabpage, 1)
        vim.api.nvim_set_current_win(new_focused.winid)

        for _, window in ipairs(windows_in_tabpage) do
            vim.cmd("bdelete " .. window.bufnr)
        end
    else
        vim.cmd("leftabove new")
    end

    -- If it's not a valid git file => it has been deleted.
    -- Create a new empty buffer and open current entry
    -- and add it to the diff mode.
    if git_file_exists(qf_current.module) then
        vim.cmd("Gedit " .. qf_current.module)
    end

    vim.cmd("diffthis")

    -- We only care about the first entry because we assume
    -- that "--name-status" or "--name-only"
    -- have been used when calling "G! difftool"
    local qf_context = vim.fn.getqflist({ context = 0 }).context.items[qf_idx].diff[1]
    local ref = vim.fn.FugitiveParse(qf_context.filename)[1]

    -- open previous state of the entry and add it to the diff mode
    vim.cmd("leftabove vnew")
    if git_file_exists(ref) then
        vim.cmd("Gedit " .. ref)
        vim.cmd("diffthis")
    end

    -- go to the previous window
    vim.cmd("wincmd p")
end

function M.next()
    local idx = vim.fn.getqflist({ idx = 0 }).idx
    vim.fn.setqflist({}, "a", { idx = idx + 1 })

    M.diff()
end

function M.previous()
    local idx = vim.fn.getqflist({ idx = 0 }).idx
    vim.fn.setqflist({}, "a", { idx = idx - 1 })

    M.diff()
end

return M
