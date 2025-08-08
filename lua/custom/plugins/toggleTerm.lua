return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      open_mapping = [[<C-\>]],
      direction = 'float',
      -- Start interactive PowerShell that won't exit immediately:
      shell = 'pwsh.exe -NoLogo -NoProfile -NoExit',
      -- If you want to see errors instead of auto-closing on failure:
      -- close_on_exit = false,
    },
  },
}
