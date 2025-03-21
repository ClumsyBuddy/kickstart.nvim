return {
  {
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
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
