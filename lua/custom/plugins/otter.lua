return {
  {
    'jmbuhr/otter.nvim',
    lazy = true,
    enabled = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'neovim/nvim-lspconfig',
    },
    config = function()
      require('otter').setup {
        buffers = {
          -- set_filetype = true, -- Automatically set filetype for embedded code
        },
      }
      -- TODO need to figure out how to localize otter to only the script tag
      -- Attach to new buffers when they open
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave', 'TextChanged', 'BufNewFile' }, {
        pattern = '*.html',
        callback = function()
          require('otter').activate(
            { 'javascript' },
            true,
            true,
            [[
              (script_element
                (start_tag
                  (attribute
                    (attribute_name) @attr_name (#eq? @attr_name "type")
                    (quoted_attribute_value (attribute_value) @attr_value (#match? @attr_value "javascript"))
                  )
                )?
                (raw_text) @injection.content
                (#set! injection.language "javascript")
              )
            ]]
          )
        end,
      })
    end,
  },
}
