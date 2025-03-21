return {
  -- NOTE:
  -- Plugin to color hex codes
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
}
