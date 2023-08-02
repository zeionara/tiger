-- package.path = package.path .. ";../lua/?.lua"

-- elixir ls

-- local util = require("util")
-- 
-- require('lspconfig').elixirls.setup({
--     cmd = { util.path_join(os.getenv('ELIXIR_LS_ROOT'), 'language_server.sh') },
--     settings = {
--         elixirLS = {
--             -- dialyzerEnabled = false,
--             -- dialyzerWarnOpts = {
--             --   'no_match'
--             -- }
--         }
--     }
-- })

-- lexical ls

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

local lexical_config = {
    filetypes = { "elixir", "eelixir" },
    -- cmd = { "/usr/local/lexical/start.sh" },
    cmd = { "/usr/local/lexical/_build/dev/rel/lexical/start_lexical.sh" },
    settings = {}
}

local attach = function(client)
    print('Lexical has started')
end

if not configs.lexical then
    configs.lexical = {
        default_config = {
            filetypes = lexical_config.filetypes,
            cmd = lexical_config.cmd,
            root_dir = function(fname)
                return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
            end,
            settings = lexical_config.settings
        }
    }
end

lspconfig.lexical.setup({
    on_attach = attach
})
