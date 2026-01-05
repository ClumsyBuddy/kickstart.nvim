local M = {}

local function try_snacks(fn_name)
  local ok, spicker = pcall(require, 'snacks.picker')
  if not ok or not spicker then
    return nil
  end
  -- map common telescope names to snacks picker names
  local map = {
    find_files = 'files',
    live_grep = 'grep',
    help_tags = 'help',
    keymaps = 'keymaps',
    current_buffer_fuzzy_find = 'lines',
    marks = 'marks',
    man_pages = 'man',
    git_commits = 'git_log',
    buffers = 'buffers',
    quickfix = 'qflist',
    loclist = 'loclist',
    jumplist = 'jumps',
    colorscheme = 'colorschemes',
  }
  local snack_name = map[fn_name] or fn_name
  -- try direct function first (snacks.picker.files)
  if type(spicker[snack_name]) == 'function' then
    return spicker[snack_name]
  end
  -- otherwise try calling pick with the source name
  if type(spicker.pick) == 'function' then
    return function(...)
      return spicker.pick(snack_name, ...)
    end
  end
  return nil
end

local function try_telescope(fn_name)
  local ok, builtin = pcall(require, 'telescope.builtin')
  if not ok or not builtin then
    return nil
  end
  return builtin[fn_name]
end

local function call_picker(fn_name, ...)
  local f = try_snacks(fn_name)
  if f then
    return f(...)
  end
  local t = try_telescope(fn_name)
  if t then
    return t(...)
  end
  vim.notify('No picker available: ' .. fn_name, vim.log.levels.WARN)
end

function M.find_files(...)
  return call_picker('find_files', ...)
end

function M.live_grep(...)
  return call_picker('live_grep', ...)
end

function M.help_tags(...)
  return call_picker('help_tags', ...)
end

function M.keymaps(...)
  return call_picker('keymaps', ...)
end

function M.current_buffer_fuzzy_find(...)
  return call_picker('current_buffer_fuzzy_find', ...)
end

function M.marks(...)
  return call_picker('marks', ...)
end

function M.man_pages(...)
  return call_picker('man_pages', ...)
end

function M.git_commits(...)
  return call_picker('git_commits', ...)
end

function M.buffers(...)
  return call_picker('buffers', ...)
end

function M.quickfix(...)
  return call_picker('quickfix', ...)
end

function M.loclist(...)
  return call_picker('loclist', ...)
end

function M.jumplist(...)
  return call_picker('jumplist', ...)
end

function M.colorscheme(...)
  return call_picker('colorscheme', ...)
end

return M
