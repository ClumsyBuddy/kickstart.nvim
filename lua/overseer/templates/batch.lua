local files = require 'overseer.files'

return {
  generator = function(opts, cb)
    local scripts = vim.tbl_filter(function(filename)
      return filename:match '%.bat$'
    end, require('overseer.files').list_files(opts.dir))
    local templates = {}
    for _, filename in ipairs(scripts) do
      table.insert(templates, {
        name = filename,
        desc = 'Run ' .. filename,
        params = {
          args = { optional = true, type = 'list', delimiter = ' ' },
        },
        builder = function(params)
          return {
            cmd = { require('overseer.files').join(opts.dir, filename) },
            args = params.args,
          }
        end,
      })
    end
    -- Instead of cb(ret), return the list directly
    cb(templates, true) -- true = these are templates, not tasks
  end,
}
