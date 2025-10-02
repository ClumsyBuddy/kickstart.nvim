return {
  -- NOTE:
  -- Allows toggling terminal like in vscode
  {
    'akinsho/toggleterm.nvim',
    enabled = function()
      return not vim.g.vscode
    end,
    version = '*',
    opts = {
      open_mapping = [[<C-\>]],
      size = function(term)
        if term.direction == 'horizontal' then
          return 10
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      name = 'mainTerm',
    },
  },
}
