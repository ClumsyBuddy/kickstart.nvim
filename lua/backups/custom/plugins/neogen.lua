return {
  'danymat/neogen',
  config = function(opts, _)
    require('neogen').setup {}
    vim.api.nvim_set_keymap('n', '<leader>cng', ":lua require('neogen').generate()", { noremap = true, silent = true, desc = 'Generate annotation' })
  end,
}
