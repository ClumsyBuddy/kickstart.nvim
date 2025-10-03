return {
  {
    'stevearc/resession.nvim',
    enabled = function()
      return not vim.g.vscode
    end,
    config = function()
      require('resession').setup {
        auto_save = true,
        auto_load = true,
        auto_save_ignore_filetypes = { 'TelescopePrompt', 'NvimTree' },
        auto_save_ignore_buftypes = { 'terminal' },
        auto_save_ignore_dirs = { 'node_modules', '.git' },
      }
      vim.keymap.set('n', '<leader>vrs', require('resession').save, { desc = 'Save Session' })
      vim.keymap.set('n', '<leader>vrl', require('resession').load, { desc = 'Load Session' })
      vim.keymap.set('n', '<leader>vrd', require('resession').delete, { desc = 'Delete Session' })
    end,
  },
  {
    'stevearc/overseer.nvim',
    config = function()
      require('overseer').setup {
        templates = {
          { name = 'Default', command = 'echo "Hello, World!"' },
          { name = 'Build', command = 'make' },
          { name = 'Test', command = 'make test' },
        },
        task_list = {
          default_action = 'run',
          show_output_on_run = true,
        },
      }
    end,
  },
}
