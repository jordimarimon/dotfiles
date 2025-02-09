local M = {}

function M.redirect(cmd)
    local window_ids = vim.api.nvim_list_wins()

    for _, win in ipairs(window_ids) do
        local ok, _ = pcall(vim.api.nvim_win_get_var, win, "scratch")

        if ok then
            vim.cmd(win .. "windo close")
        end
    end

    local output = ""
    if string.sub(cmd, 1, 1) == "!" then
        -- Execute shell command
        output = vim.fn.system(string.sub(cmd, 2))
    else
        -- Execute vim command
        output = vim.fn.execute(cmd)
    end

    local lines = vim.split(output, "\n")
    local scratch_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_text(scratch_buffer, 0, 0, 0, 0, lines)

    -- Split window vertically and edit buffer [N] from the buffer list
    vim.cmd("vertical sbuffer " .. scratch_buffer)
    vim.api.nvim_win_set_var(0, "scratch", 1)

    vim.opt_local.wrap = true
    vim.opt_local.buftype = "nofile"
    vim.opt_local.bufhidden = "wipe"
    vim.opt_local.swapfile = false

    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = scratch_buffer })
end

return M
