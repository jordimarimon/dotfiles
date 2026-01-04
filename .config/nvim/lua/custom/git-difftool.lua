-- Based on: https://github.com/jecaro/fugitive-difftool.nvim/tree/main
-- Usage: `:G! difftool --name-status {branch1}...{branch2}`

local M = {}
local String = require("custom.string")

local function git_file_exists(obj)
    local job_id = vim.fn.jobstart({ "git", "cat-file", "-e", obj })
    local result = vim.fn.jobwait({ job_id })
    return #result == 1 and result[1] == 0
end

function M.review(query)
    local branches_cmd = vim.system(
        { "git", "branch", "--all", "--remotes", "--no-color" },
        { text = true }
    )
        :wait()
    local branches = String.split(branches_cmd.stdout, "\n")
    local review_branch = nil
    local other_branches = {}

    for index, branch in ipairs(branches) do
        branch_name, _ = String.trim(branch):gsub("%s%->.+$", "")
        branches[index] = branch_name

        if review_branch == nil and branch_name:find(query, 1, true) ~= nil then
            review_branch = branch_name
        else
            table.insert(other_branches, branch_name)
        end
    end

    if review_branch == nil then
        vim.notify("Unable to find branch to review", vim.log.levels.ERROR)
        return
    end

    local git_log_cmd = { "git", "log", "--pretty=format:'%h'", review_branch }
    for _, other_branch in ipairs(other_branches) do
        table.insert(git_log_cmd, "^" .. other_branch)
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

    -- Make sure the current entry is a valid git file
    if not git_file_exists(qf_current.module) then
        vim.notify("Current entry in quickfix list is not a git file", vim.log.levels.ERROR)
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

    -- Create a new empty buffer and open current entry
    -- and add it to the diff mode
    vim.cmd("Gedit " .. qf_current.module)
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
