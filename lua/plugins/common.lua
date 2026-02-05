return {
  -- common dependencies
  { 'nvim-lua/plenary.nvim' },

  -- auto-detect indentation
  { 'tpope/vim-sleuth' },

  -- commenting
  {
    'numToStr/Comment.nvim',
    lazy = true,
    opts = {
      toggler = {
        line = 'gl', -- moved from 'gcc'
        block = 'gbc',
      },
      opleader = {
        line = 'gc',
        block = 'gb',
      },
    },
  },

  -- git signs in gutter
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- lua development helpers
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- highlight TODO comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
}
