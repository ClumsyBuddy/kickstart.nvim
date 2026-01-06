return {
  {
    'gelguy/wilder.nvim',
    event = 'CmdlineEnter',
    dependencies = { 'romgrk/fzy-lua-native' },
    config = function()
      local wilder = require('wilder')
      wilder.setup({ modes = { ':', '/', '?' } })

      -- pipeline: fuzzy for cmdline, search pipeline for searches
      wilder.set_option('pipeline', {
        wilder.branch(
          wilder.cmdline_pipeline({
            fuzzy = 1,
            fuzzy_filter = wilder.lua_fzy_filter(),
          }),
          wilder.search_pipeline()
        ),
      })

      -- simple popupmenu renderer
      wilder.set_option('renderer', wilder.popupmenu_renderer({
        highlighter = wilder.basic_highlighter(),
        left = { ' ', wilder.popupmenu_devicons() },
        right = { ' ', wilder.popupmenu_scrollbar() },
      }))
    end,
  },
}
