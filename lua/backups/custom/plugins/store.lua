return {
  'alex-popov-tech/store.nvim',
  enabled = function()
    return not vim.g.vscode
  end,
  dependencies = { 'OXY2DEV/markview.nvim' },
  cmd = 'Store',
}
