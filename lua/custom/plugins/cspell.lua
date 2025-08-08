return {
  {
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
    enabled = false,
    dependencies = { 'davidmh/cspell.nvim' },
    config = function()
      local cspell = require 'cspell'
      require('null-ls').setup {
        sources = {
          cspell.diagnostics,
          cspell.code_actions,
        },
      }
    end,
  },
}
