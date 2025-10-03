return {
  'kylechui/nvim-surround',
  version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      -- Switch from ys/yss/yS/ySS to gs/gss/gS/gSS to avoid yank-prefix overlaps
      keymaps = {
        normal = 'gs', -- add around a motion
        normal_cur = 'gss', -- add around current line
        normal_line = 'gS', -- add around a motion, on new lines
        normal_cur_line = 'gSS', -- add around current line, on new lines
        visual = 'S', -- add surrounding in visual mode
        delete = 'ds',
        change = 'cs',
      },
    }
  end,
}
