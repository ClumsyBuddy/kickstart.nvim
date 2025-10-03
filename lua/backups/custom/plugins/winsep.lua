return {
  -- NOTE:
  -- Plugin to add color separator between windows.
  -- This is just to make it easier to tell the difference
  {
    'nvim-zh/colorful-winsep.nvim',
    lazy = true,
    config = true,
    event = { 'WinLeave' },
  },
}
