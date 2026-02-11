-- required in which-key plugin spec in plugins/ui.lua as `require 'config.keymap'`
local wk = require 'which-key'

P = vim.print


local nmap = function(key, effect, description)
  description = description or ""
  vim.keymap.set('n', key, effect, { silent = true, noremap = true, desc=description})
end

local vmap = function(key, effect, description)
  description = description or ""
  vim.keymap.set('v', key, effect, { silent = true, noremap = true, desc=description})
end

local imap = function(key, effect, description)
  description = description or ""
  vim.keymap.set('i', key, effect, { silent = true, noremap = true, desc=description })
end

local cmap = function(key, effect, description)
  description = description or ""
  vim.keymap.set('c', key, effect, { silent = true, noremap = true, desc=description })
end

-- move in command line
cmap('<C-a>', '<Home>')

-- save with ctrl+s
-- imap('<C-s>', '<esc>:update<cr><esc>')
-- nmap('<C-s>', '<cmd>:update<cr><esc>')

-- Move between windows using <ctrl> direction
nmap('<C-j>', '<C-W>j')
nmap('<C-k>', '<C-W>k')
nmap('<C-h>', '<C-W>h')
nmap('<C-l>', '<C-W>l')

-- Resize window using <shift> arrow keys
nmap('<S-Up>', '<cmd>resize +2<CR>')
nmap('<S-Down>', '<cmd>resize -2<CR>')
nmap('<S-Left>', '<cmd>vertical resize +2<CR>')
nmap('<S-Right>', '<cmd>vertical resize -2<CR>')

-- Add undo break-points
-- imap(',', ',<c-g>u')
-- imap('.', '.<c-g>u')
-- imap(';', ';<c-g>u')
--
-- nmap('Q', '<Nop>')

-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- move between splits and tabs
nmap('<c-h>', '<c-w>h')
nmap('<c-l>', '<c-w>l')
nmap('<c-j>', '<c-w>j')
nmap('<c-k>', '<c-w>k')
nmap('H', '<cmd>tabprevious<cr>')
nmap('L', '<cmd>tabnext<cr>')

local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end


--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end


local insert_py_chunk = function()
  insert_code_chunk 'python'
end

local insert_lua_chunk = function()
  insert_code_chunk 'lua'
end

local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end




local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end


--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
  { '<c-LeftMouse>', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = 'go to definition' },
  { '<c-q>', '<cmd>q<cr>', desc = 'close buffer' },
  { '<esc>', '<cmd>noh<cr>', desc = 'remove search highlight' },
  { 'gf', ':e <cfile><CR>', desc = 'edit file' },
  { '<C-M-i>', insert_py_chunk, desc = 'python code chunk' },
  { '<m-I>', insert_py_chunk, desc = 'python code chunk' },
  { ']q', ':silent cnext<cr>', desc = '[q]uickfix next' },
  { '[q', ':silent cprev<cr>', desc = '[q]uickfix prev' },
  { 'z?', ':setlocal spell!<cr>', desc = 'toggle [z]pellcheck' },
  { 'zl', ':Telescope spell_suggest<cr>', desc = '[l]ist spelling suggestions' },
}, { mode = 'n', silent = true })

-- visual mode
wk.add({
  { '<M-j>', ":m'>+<cr>`<my`>mzgv`yo`z", desc = 'move line down' },
  { '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z", desc = 'move line up' },
  { '.', ':norm .<cr>', desc = 'repeat last normal mode command' },
  { '<C-q>', ':norm @q<cr>', desc = 'repeat q macro' },
}, { mode = 'v' })

-- visual with <leader>
wk.add {
  { '<leader>p', '"_dP', desc = 'replace without overwriting reg', mode = 'v' },
  { '<leader>d', '"_d', desc = 'delete without overwriting reg', mode = 'v' },
}

-- insert mode
wk.add {
  { '<m-->', ' <- ', desc = 'assign', mode = 'i' },
  { '<m-m>', ' |>', desc = 'pipe', mode = 'i' },
  { '<C-M-i>', insert_py_chunk, desc = 'python code chunk', mode = 'i' },
  { '<m-I>', insert_py_chunk, desc = 'python code chunk', mode = 'i' },
  { '<c-x><c-x>', '<c-x><c-o>', desc = 'omnifunc completion', mode = 'i' },
}

local function new_terminal_python()
  new_terminal 'uv run python'
end


local function new_terminal_ipython()
  new_terminal 'uv tool run ipython --no-confirm-exit'
end


-- normal mode with <leader>
wk.add({
  { '<leader>c', group = '[c]ode / [c]ell / [c]hunk' },
  { '<leader>cp', new_terminal_python, desc = 'new [p]ython terminal' },
  { '<leader>ci', new_terminal_ipython, desc = 'new [i]python terminal' },
  { '<leader>e', group = '[e]dit' },
  { '<leader>d', group = '[d]ebug' },
  { '<leader>dt', group = '[t]est' },
  { '<leader>f', group = '[f]ind (snacks)' },
  { '<leader>s', group = '[s]earch' },
  { '<leader>m', group = '[m]isc' },
  { '<leader>b', group = '[b]uffer' },
  { '<leader>ff', function() require('misc.pickers').find_files() end, desc = '[f]iles' },
  { '<leader>fh', function() require('misc.pickers').help_tags() end, desc = '[h]elp' },
  { '<leader>fk', function() require('misc.pickers').keymaps() end, desc = '[k]eymaps' },
  { '<leader>fg', function() require('misc.pickers').live_grep() end, desc = '[g]rep' },
  { '<leader>fb', function() require('misc.pickers').current_buffer_fuzzy_find() end, desc = '[b]uffer fuzzy find' },
  { '<leader>fm', function() require('misc.pickers').marks() end, desc = '[m]arks' },
  { '<leader>fM', function() require('misc.pickers').man_pages() end, desc = '[M]an pages' },
  { '<leader>fc', function() require('misc.pickers').git_commits() end, desc = 'git [c]ommits' },
  { '<leader>f<space>', function() require('misc.pickers').buffers() end, desc = '[ ] buffers' },
  { '<leader>fd', function() require('misc.pickers').buffers() end, desc = '[d] buffers' },
  { '<leader>fq', function() require('misc.pickers').quickfix() end, desc = '[q]uickfix' },
  { '<leader>fl', function() require('misc.pickers').loclist() end, desc = '[l]oclist' },
  { '<leader>fj', function() require('misc.pickers').jumplist() end, desc = '[j]umplist' },

  -- Snacks-enhanced pickers (use Snacks if available, else fall back)
  { '<leader>su', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.undo then pcall(s.undo) else vim.notify('Undo picker not available', vim.log.levels.WARN) end
    end, desc = 'Undo history' },
  { '<leader>sd', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.diagnostics then pcall(s.diagnostics) else
        local ok2, tb = pcall(require, 'telescope.builtin')
        if ok2 and tb and tb.diagnostics then tb.diagnostics() else vim.diagnostic.setqflist({ open = true }) end
      end
    end, desc = 'Diagnostics' },
  { '<leader>s/', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.search_history then pcall(s.search_history) else vim.notify('Search history not available', vim.log.levels.WARN) end
    end, desc = 'Search History' },
  { '<leader>sB', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.grep_buffers then pcall(s.grep_buffers) else require('misc.pickers').current_buffer_fuzzy_find() end
    end, desc = 'Grep Open Buffers' },
  { '<leader>sw', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.grep_word then pcall(s.grep_word) else require('misc.pickers').live_grep() end
    end, desc = 'Grep word/selection', mode = { 'n', 'x' } },

  { '<leader>g', group = '[g]it' },
  { '<leader>gc', ':GitConflictRefresh<cr>', desc = '[c]onflict' },
  { '<leader>gs', ':Gitsigns<cr>', desc = 'git [s]igns' },
  { '<leader>gg', function()
      local ok,sn = pcall(require, 'snacks')
      if ok and sn and sn.lazygit then pcall(sn.lazygit.open) else vim.cmd('vsplit | terminal lazygit') end
    end, desc = 'Lazygit' },
  { "<C-\\>", function() Snacks.terminal() end, desc = "Terminal" },
  { '<leader>td', function()
      require('trouble').open('workspace_diagnostics')
    end, desc = 'Trouble: Workspace Diagnostics' },
  { '<leader>gwc', ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", desc = 'worktree create' },
  { '<leader>gws', ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", desc = 'worktree switch' },
  { '<leader>gd', group = '[d]iff' },
  { '<leader>gdo', ':DiffviewOpen<cr>', desc = '[o]pen' },
  { '<leader>gdc', ':DiffviewClose<cr>', desc = '[c]lose' },
  { '<leader>gb', group = '[b]lame' },
  { '<leader>gbb', ':GitBlameToggle<cr>', desc = '[b]lame toggle virtual text' },
  { '<leader>gbo', ':GitBlameOpenCommitURL<cr>', desc = '[o]pen' },
  { '<leader>gbc', ':GitBlameCopyCommitURL<cr>', desc = '[c]opy' },
  { '<leader>h', group = '[h]elp / [h]ide / debug' },
  { '<leader>hc', group = '[c]onceal' },
  { '<leader>hch', ':set conceallevel=1<cr>', desc = '[h]ide/conceal' },
  { '<leader>hcs', ':set conceallevel=0<cr>', desc = '[s]how/unconceal' },
  { '<leader>ht', group = '[t]reesitter' },
  { '<leader>htt', vim.treesitter.inspect_tree, desc = 'show [t]ree' },
  { '<leader>i', group = '[i]mage' },
  { '<leader>l', group = '[l]anguage/lsp' },
  { '<leader>lr', vim.lsp.buf.references, desc = '[r]eferences' },
  { '<leader>lR', vim.lsp.buf.rename, desc = '[R]ename' },
  { '<leader>lD', vim.lsp.buf.type_definition, desc = 'type [D]efinition' },
  { '<leader>la', vim.lsp.buf.code_action, desc = 'code [a]ction' },
  { '<leader>le', vim.diagnostic.open_float, desc = 'diagnostics (show hover [e]rror)' },
  { '<leader>ld', group = '[d]iagnostics' },
  {
    '<leader>ldd',
    function()
      vim.diagnostic.enable(false)
    end,
    desc = '[d]isable',
  },
  { '<leader>lde', vim.diagnostic.enable, desc = '[e]nable' },
  { '<leader>ss', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.lsp_symbols then pcall(s.lsp_symbols) else vim.lsp.buf.document_symbol() end
    end, desc = 'LSP Symbols' },
  { '<leader>sS', function()
      local ok,s = pcall(require, 'snacks.picker')
      if ok and s and s.lsp_workspace_symbols then pcall(s.lsp_workspace_symbols) else vim.lsp.buf.workspace_symbol() end
    end, desc = 'LSP Workspace Symbols' },
  { '<leader>v', group = '[v]im' },
  { '<leader>vl', ':Lazy<cr>', desc = '[l]azy package manager' },
  { '<leader>vm', ':Mason<cr>', desc = '[m]ason software installer' },
  { '<leader>vr', group = '[R]esession' },
  { '<leader>vs', ':e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>', desc = '[s]ettings, edit vimrc' },
  { '<leader>vh', ':execute "h " . expand("<cword>")<cr>', desc = 'vim [h]elp for current word' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>x', group = 'e[x]ecute' },
  { '<leader>xx', ':w<cr>:source %<cr>', desc = '[x] source %' },
  { '<leader>a', group = '[A]i tools' },
  { '<leader>st', ':Store<cr>', desc = 'Open Store' },
}, { mode = 'n' })
