return {
  'neoclide/coc.nvim',
  enabled = false,
  branch = 'release',
  build = 'npm install',
  config = function()
    vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { desc = 'Coc: Goto Definition' })
    vim.keymap.set('n', 'gR', '<Plug>(coc-references)', { desc = 'Coc: References' })
    vim.keymap.set('n', 'gI', '<Plug>(coc-implementation)', { desc = 'Coc: Implementation' })
    vim.keymap.set('n', '<leader>rn', '<Plug>(coc-rename)', { desc = 'Coc: Rename' })
    vim.keymap.set('n', '<leader>cla', '<Plug>(coc-codeaction-selected)', { desc = 'Coc: Code Action' })
    vim.keymap.set('x', '<leader>cla', '<Plug>(coc-codeaction-selected)', { desc = 'Coc: Code Action' })
  end,
}
