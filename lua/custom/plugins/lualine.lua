return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Add this to your lualine configuration file
    local function get_git_info()
      local branch = vim.fn.FugitiveStatusline()
      if branch ~= '' then
        local status, stdout = pcall(io.popen, 'git rev-list --count --left-right @{u}...HEAD')
        if status then
          local parts = vim.split(stdout:read('*a'):gsub('%s+', ''), '\t')
          local incoming = parts[1]
          local outgoing = parts[2]
          return string.format('↑%s ↓%s', outgoing, incoming)
        end
      end
      return ''
    end

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16, -- ~60fps
          events = {
            'WinEnter',
            'BufEnter',
            'BufWritePost',
            'SessionLoadPost',
            'FileChangedShellPost',
            'VimResized',
            'Filetype',
            'CursorMoved',
            'CursorMovedI',
            'ModeChanged',
          },
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics', get_git_info }, -- Or your existing branch component
        lualine_c = {
          function()
            return vim.fn.expand '%:.'
          end,
          'filetype',
        },
        lualine_x = { 'diagnostics' },
        -- lualine_y = { 'filetype' },
        lualine_z = {}, -- Add the new function to your statusline
      },
    }
  end,
}
