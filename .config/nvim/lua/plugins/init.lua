-- Order is important as some plugins have dependencies on others
local plugins = {
    "icons",
    "syntax",
    "mason",
    "file-explorer",
    "file-picker",
    "format",
    "mini",
    "completion",
    "markdown",
    "database",
    "git",
}

local specs = {}

for _, name in ipairs(plugins) do
    local plugin_specs = require("plugins." .. name)

    for _, spec in ipairs(plugin_specs) do
        table.insert(specs, spec)
    end
end

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name = ev.data.spec.name
        local kind = ev.data.kind

        if kind ~= "install" and kind ~= "update" then
            return
        end

        for _, spec in ipairs(specs) do
            local spec_name = spec.name or vim.fn.fnamemodify(spec.src, ":t:r")

            if spec_name == name then
                if spec.build then
                    if not ev.data.active then
                        vim.cmd.packadd(name)
                    end

                    spec.build()
                end

                break
            end
        end
    end,
})

for _, spec in ipairs(specs) do
    vim.pack.add({
        { src = spec.src, version = spec.version or nil },
    })

    if spec.setup then
        spec.setup()
    end
end
