return {
  -- NOTE:
  -- Plugin to color hex codes
  {
    'norcalli/nvim-colorizer.lua',
    lazy = true,
    config = function()
      require('colorizer').setup()
    end,
  },
}
