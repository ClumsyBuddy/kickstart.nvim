-- AI Git Commit Message Generator
-- Uses OpenCode CLI for generation
-- Cross-platform (Windows + Linux)
-- Usage: require('misc.ai-commit').commit()

local M = {}

-- Configuration
M.config = {
  num_suggestions = 3,
  prompt_template = [[You are a helpful assistant that generates git commit messages.
[SYSTEM PROMPT]
# Required
Based on the following git diff, generate exactly 3 different commit message options.
Keep messages clear and concise. Capture main subject of changes without going into to much detail. Avoid generic messages like "update" or "changes".
Output ONLY the 3 commit messages, one per line, numbered like:
1. message one
2. message two
3. message three

# Recommended
Follow conventional commits format when appropriate (feat:, fix:, docs:, refactor:, chore:, test:, style:), this is not a requirement but a formatting suggestion.
Do not include any explanation or extra text.


[INPUT]
Git diff:
%s]],
}

-- State
local state = {
  current_model = nil, -- model name string (e.g., "github-copilot/claude-sonnet-4")
  available_models = nil, -- Cached list of models
}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

--- Notify helper using Snacks if available
---@param msg string
---@param level? number
local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "AI Commit" })
  end)
end

--- Show loading indicator with spinner animation
---@param msg string
---@return function stop function to stop the loading indicator
local function show_loading(msg)
  local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local frame_idx = 1
  local timer = vim.uv.new_timer()

  -- Use Snacks notifier if available
  local ok, snacks = pcall(require, 'snacks')

  local function update()
    vim.schedule(function()
      local spinner = frames[frame_idx]
      frame_idx = (frame_idx % #frames) + 1

      if ok and snacks and snacks.notifier then
        snacks.notifier.notify(spinner .. " " .. msg, "info", {
          id = "ai_commit_loading",
          title = "AI Commit",
          timeout = false,
        })
      else
        vim.api.nvim_echo({ { spinner .. " " .. msg, "DiagnosticInfo" } }, false, {})
      end
    end)
  end

  update()
  timer:start(100, 100, update)

  return function()
    timer:stop()
    timer:close()
    vim.schedule(function()
      if ok and snacks and snacks.notifier then
        snacks.notifier.hide("ai_commit_loading")
      else
        vim.api.nvim_echo({ { "", "" } }, false, {})
      end
    end)
  end
end

--- Check if we're in a git repository
---@return boolean
local function is_git_repo()
  local result = vim.system({ 'git', 'rev-parse', '--git-dir' }, { text = true }):wait()
  return result.code == 0
end

--- Get git diff (staged first, fallback to unstaged)
---@return string|nil diff
---@return string|nil error
local function get_git_diff()
  local result = vim.system({ 'git', 'diff', '--staged' }, { text = true }):wait()
  if result.code == 0 and result.stdout and #result.stdout > 0 then
    return result.stdout, nil
  end

  result = vim.system({ 'git', 'diff' }, { text = true }):wait()
  if result.code == 0 and result.stdout and #result.stdout > 0 then
    return result.stdout, nil
  end

  return nil, "No changes to commit (no staged or unstaged changes)"
end

--- Parse commit messages from AI response
---@param response string
---@return string[]
local function parse_commit_messages(response)
  local messages = {}

  -- Try to parse numbered messages (1. xxx, 2. xxx, etc.)
  for line in response:gmatch("[^\r\n]+") do
    local msg = line:match("^%d+[%.%)%:%s]+(.+)$")
    if msg then
      msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
      if #msg > 0 then
        table.insert(messages, msg)
      end
    end
  end

  -- Fallback: use non-empty lines
  if #messages == 0 then
    for line in response:gmatch("[^\r\n]+") do
      line = line:gsub("^%s+", ""):gsub("%s+$", "")
      if #line > 0 and #messages < M.config.num_suggestions then
        table.insert(messages, line)
      end
    end
  end

  return messages
end

--- Copy message to clipboard
---@param msg string
local function copy_to_clipboard(msg)
  vim.fn.setreg('+', msg)
  vim.fn.setreg('"', msg)
  notify("Copied to clipboard: " .. msg)
end

--- Run git commit with message
---@param msg string
local function run_git_commit(msg)
  vim.system({ 'git', 'commit', '-m', msg }, { text = true }, function(result)
    if result.code == 0 then
      notify("Committed: " .. msg, vim.log.levels.INFO)
    else
      local err = result.stderr or result.stdout or "Unknown error"
      notify("Commit failed: " .. err, vim.log.levels.ERROR)
    end
  end)
end

--------------------------------------------------------------------------------
-- OpenCode Integration
--------------------------------------------------------------------------------

--- Fetch available models from OpenCode CLI
---@param callback fun(models: string[]|nil, err: string|nil)
local function fetch_models(callback)
  vim.system({ 'opencode', 'models' }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        callback(nil, "Failed to fetch models. Is OpenCode installed?")
        return
      end

      local models = vim.split(result.stdout, "\n", { trimempty = true })
      if #models == 0 then
        callback(nil, "No models available")
        return
      end

      state.available_models = models
      callback(models, nil)
    end)
  end)
end

--- Generate commit messages using OpenCode CLI
---@param model string
---@param diff string
---@param callback fun(messages: string[]|nil, err: string|nil)
local function generate_messages(model, diff, callback)
  -- Write diff to temp file for --file attachment
  local diff_file = vim.fn.tempname() .. ".diff"
  local f = io.open(diff_file, 'w')
  if not f then
    callback(nil, "Failed to create temp file")
    return
  end
  f:write(diff)
  f:close()

  local prompt = [[Generate exactly 3 git commit messages for the attached diff file.
Follow conventional commits format (feat:, fix:, docs:, refactor:, chore:, test:, style:).
Keep messages concise (under 72 characters).
Output ONLY the 3 commit messages, numbered 1-3, one per line. No explanations.]]

  -- Command: opencode run -m <model> -f <file> -- <message>
  vim.system(
    { 'opencode', 'run', '-m', model, '-f', diff_file, '--', prompt },
    { text = true },
    function(result)
      os.remove(diff_file)

      if result.code ~= 0 then
        local err = result.stderr or result.stdout or "Unknown error"
        callback(nil, "OpenCode error: " .. err)
        return
      end

      local response = result.stdout or ""
      local messages = parse_commit_messages(response)

      if #messages == 0 then
        callback(nil, "Could not parse commit messages from response")
        return
      end

      callback(messages, nil)
    end
  )
end

--------------------------------------------------------------------------------
-- Model Selection UI
--------------------------------------------------------------------------------

--- Show model picker
---@param models string[]
---@param callback fun(selection: string|nil)
local function show_model_picker(models, callback)
  vim.schedule(function()
    local ok, picker = pcall(require, 'snacks.picker')

    if ok and picker and picker.pick then
      local items = {}
      for _, model in ipairs(models) do
        local is_current = state.current_model == model
        table.insert(items, {
          text = model,
          model = model,
          is_current = is_current,
        })
      end

      picker.pick({
        source = "select",
        items = items,
        prompt = "Select Model",
        format = function(item)
          local prefix = item.is_current and "* " or "  "
          local hl = item.is_current and "DiagnosticOk" or nil
          return { { prefix .. item.text, hl } }
        end,
        confirm = function(p, item)
          if item then
            p:close()
            state.current_model = item.model
            callback(item.model)
          end
        end,
      })
    else
      -- Fallback to vim.ui.select
      local display_items = {}
      for _, model in ipairs(models) do
        local prefix = (state.current_model == model) and "* " or "  "
        table.insert(display_items, prefix .. model)
      end

      vim.ui.select(display_items, {
        prompt = "Select Model:",
      }, function(choice)
        if choice then
          local model = choice:gsub("^[%*%s]+", "")
          state.current_model = model
          callback(model)
        else
          callback(nil)
        end
      end)
    end
  end)
end

--- Show commit message picker
---@param messages string[]
local function show_message_picker(messages)
  vim.schedule(function()
    local items = {}
    for i, msg in ipairs(messages) do
      table.insert(items, { idx = i, text = msg, msg = msg })
    end

    local ok, picker = pcall(require, 'snacks.picker')

    if ok and picker and picker.pick then
      picker.pick({
        source = "select",
        items = items,
        prompt = "Select Commit Message",
        format = function(item)
          return { { item.idx .. ". ", "DiagnosticInfo" }, { item.msg } }
        end,
        confirm = function(p, item)
          if item then
            p:close()
            vim.ui.select(
              { "[c] Copy to clipboard", "[C] Copy + Commit" },
              { prompt = "Action:" },
              function(choice)
                if choice then
                  copy_to_clipboard(item.msg)
                  if choice:match("^%[C%]") then
                    run_git_commit(item.msg)
                  end
                end
              end
            )
          end
        end,
        actions = {
          copy = function(p, item)
            if item then
              p:close()
              copy_to_clipboard(item.msg)
            end
          end,
          commit = function(p, item)
            if item then
              p:close()
              copy_to_clipboard(item.msg)
              run_git_commit(item.msg)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["c"] = { "copy", desc = "Copy to clipboard", mode = { "n", "i" } },
              ["C"] = { "commit", desc = "Copy + Commit", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["c"] = { "copy", desc = "Copy to clipboard", mode = { "n" } },
              ["C"] = { "commit", desc = "Copy + Commit", mode = { "n" } },
            },
          },
        },
      })
    else
      vim.ui.select(messages, {
        prompt = "Select Commit Message:",
      }, function(choice)
        if choice then
          vim.ui.select(
            { "[c] Copy to clipboard", "[C] Copy + Commit" },
            { prompt = "Action:" },
            function(action)
              if action then
                copy_to_clipboard(choice)
                if action:match("^%[C%]") then
                  run_git_commit(choice)
                end
              end
            end
          )
        end
      end)
    end
  end)
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Select/change model (always shows picker)
function M.select_model()
  fetch_models(function(models, err)
    if err then
      notify(err, vim.log.levels.ERROR)
      return
    end

    show_model_picker(models, function(selection)
      if selection then
        notify("Model set to: " .. selection)
      end
    end)
  end)
end

--- Main entry point - generate commit messages
function M.commit()
  -- Check if in git repo
  if not is_git_repo() then
    notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Get diff (no truncation - let OpenCode handle context limits)
  local diff, diff_err = get_git_diff()
  if not diff then
    notify(diff_err or "No changes to commit", vim.log.levels.WARN)
    return
  end

  -- Fetch models
  fetch_models(function(models, err)
    if err then
      notify(err, vim.log.levels.ERROR)
      return
    end

    -- Check if cached model is still valid
    local cached_valid = false
    if state.current_model then
      for _, model in ipairs(models) do
        if model == state.current_model then
          cached_valid = true
          break
        end
      end
    end

    -- Function to generate with selected model
    local function generate_with_model(model)
      local stop_loading = show_loading("Generating with " .. model .. "...")

      generate_messages(model, diff, function(messages, gen_err)
        stop_loading()

        if gen_err then
          notify(gen_err, vim.log.levels.ERROR)
          return
        end

        if not messages or #messages == 0 then
          notify("No commit messages generated", vim.log.levels.WARN)
          return
        end

        show_message_picker(messages)
      end)
    end

    -- Use cached model or show picker
    if cached_valid then
      notify("Using model: " .. state.current_model)
      generate_with_model(state.current_model)
    else
      -- Clear invalid cache
      if state.current_model and not cached_valid then
        state.current_model = nil
      end

      show_model_picker(models, function(selection)
        if not selection then
          notify("Cancelled", vim.log.levels.INFO)
          return
        end
        generate_with_model(selection)
      end)
    end
  end)
end

return M
