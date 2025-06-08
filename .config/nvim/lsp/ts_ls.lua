-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ts_ls.lua
---@type vim.lsp.Config
return {
    init_options = { hostInfo = "neovim" },

    cmd = { "typescript-language-server", "--stdio" },

    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },

    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },

    workspace_required = true,

    handlers = {
        -- handle rename request for certain code actions
        -- like extracting functions / types
        ["_typescript.rename"] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            vim.lsp.util.show_document({
                uri = result.textDocument.uri,
                range = {
                    start = result.position,
                    ["end"] = result.position,
                },
            }, client.offset_encoding)

            vim.lsp.buf.rename()

            return vim.NIL
        end,
    },

    on_attach = function(client, bufnr)
        local file = vim.api.nvim_buf_get_name(bufnr)

        -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
        -- `vim.lsp.buf.code_action()` if specified in `context.only`.
        vim.api.nvim_buf_create_user_command(0, "SourceAction", function()
            local source_actions = vim.tbl_filter(function(action)
                return vim.startswith(action, "source.")
            end, client.server_capabilities.codeActionProvider.codeActionKinds)

            vim.lsp.buf.code_action({
                context = {
                    only = source_actions,
                    diagnostics = {},
                },
            })

            -- https://github.com/typescript-language-server/typescript-language-server/blob/master/src/commands.ts
            vim.api.nvim_buf_create_user_command(bufnr, "OrganizeImports", function()
                ---@type lsp.Command
                local cmd = {
                    command = "_typescript.organizeImports",
                    arguments = { file },
                    title = ""
                }

                client:exec_cmd(cmd)
            end, { nargs = 0 })

            vim.api.nvim_buf_create_user_command(bufnr, "RenameFile", function()
                vim.ui.input({ prompt = "New name: " }, function(input)
                    if input == nil or #input == 0 then
                        return
                    end

                    local dir = require("custom.fs").dir()

                    ---@type lsp.Command
                    local cmd = {
                        command = "_typescript.applyRenameFile",
                        arguments = {
                            {
                                sourceUri = file,
                                targetUri = dir .. "/" .. input,
                            },
                        },
                        title = ""
                    }

                    client:exec_cmd(cmd)
                end)
            end, { nargs = 0 })

            vim.api.nvim_buf_create_user_command(bufnr, "RemoveUnusedImports", function()
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        diagnostics = {},
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        only = { "source.removeUnusedImports" },
                    },
                })
            end, { nargs = 0 })

            vim.api.nvim_buf_create_user_command(bufnr, "AddMissingImports", function()
                vim.lsp.buf.code_action({
                    apply = true,
                    context = {
                        diagnostics = {},
                        ---@diagnostic disable-next-line: assign-type-mismatch
                        only = { "source.addMissingImports" },
                    },
                })
            end, { nargs = 0 })
        end, {})
    end,

    on_init = function(client, _)
        client.server_capabilities.semanticTokensProvider = nil
    end,
}
