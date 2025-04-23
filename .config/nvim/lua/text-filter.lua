-- ~/.config/nvim/lua/text-filter.lua
local api = vim.api
local M = {}

-- TODO:
-- * Add more colors
-- * Allow use color shortcut, e.g., b for blue
-- * Save/load patterns to/from file

local color_to_hl_group = {
  green = "TextFilterHighlightGroupGreen",
  blue  = "TextFilterHighlightGroupBlue",
}

-- Hide (fold) the lines from start_line to end_line
function M.hide_range(start_line, end_line)
  -- make sure manual folding is on
  vim.wo.foldmethod = "manual"
  -- create the fold
  vim.cmd(string.format("%d,%dfold", start_line, end_line))
end

-- Unhide (open) the fold that starts at start_line
function M.unhide_range(start_line)
  -- open any fold at that line
  vim.cmd(string.format("%dfoldopen!", start_line))
end

-- Toggle fold between start and end
function M.toggle_range(start_line, end_line)
  -- check if there's already a closed fold at start_line
  local is_closed = vim.fn.foldclosed(start_line) ~= -1
  if is_closed then
    M.unhide_range(start_line)
  else
    M.hide_range(start_line, end_line)
  end
end

function filter_by_pattern(lines, pattern)
  local new_lines = {}
  for _, line in ipairs(lines) do
    if line:match(pattern) then
      table.insert(new_lines, line)
    end
  end
  return new_lines
end

function M.filter(pattern)
  local buf = api.nvim_get_current_buf()
  if vim.b.filtered then
    vim.notify("Already filtered; use :Unfilter first", vim.log.levels.WARN)
    return
  end
  -- Read all lines
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  -- Backup original
  vim.b.original_lines = lines
  vim.b.filtered = true
  local new_lines = filter_by_pattern(lines, pattern)
  -- Apply filtered content
  api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
end

function M.filter_to_new_buf(pattern)
  local scratch_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(scratch_buf, "buftype", "nofile")
  api.nvim_buf_set_option(scratch_buf, "bufhidden", "wipe")

  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local new_lines = filter_by_pattern(lines, pattern)
  api.nvim_buf_set_lines(scratch_buf, 0, -1, false, new_lines)

  local win = api.nvim_open_win(scratch_buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    style = "minimal", border = "single"
  })
end

-- Restore the original lines
function M.unfilter()
  local buf = api.nvim_get_current_buf()
  if not vim.b.filtered then
    vim.notify("Buffer not filtered", vim.log.levels.WARN)
    return
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.b.original_lines)
  vim.b.filtered = nil
  vim.b.original_lines = nil
end

function M.add_filter_pattern(pattern, group)
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local hl_group = color_to_hl_group[group]
  hl_group = hl_group or color_to_hl_group['blue']
  api.nvim_set_hl_ns(M.ns)
  for linenr, text in ipairs(lines) do
    local start_col = 1
    while true do
      -- string.find returns byte‐indices; convert to 0‐based
      local s, e = string.find(text, pattern, start_col)
      if not s then break end

      api.nvim_buf_add_highlight(buf, M.ns, hl_group, linenr - 1, 0, -1)
      -- highlight group “MyPluginMatch” must be defined elsewhere
      api.nvim_buf_add_highlight( buf, M.ns, "TextFilterHighlightGroupKey",
	linenr - 1, s - 1, e)

      -- continue search just after this match
      start_col = e + 1
    end
  end

  local filter_patterns = vim.b.filter_patterns or {}
  table.insert(filter_patterns, {pattern, hl_group})
  vim.b.filter_patterns = filter_patterns
end

function M.filter_by_saved_patterns()
  if vim.b.filter_patterns == nil then
    vim.notify("No patterns added", vim.log.levels.WARN)
    return
  end

  local scratch_buf = api.nvim_create_buf(false, true) -- (listed, scratch)
  api.nvim_buf_set_option(scratch_buf, "buftype", "nofile")
  api.nvim_buf_set_option(scratch_buf, "bufhidden", "wipe")

  local lines = api.nvim_buf_get_lines(api.nvim_get_current_buf(), 0, -1, false)

  local inserted_count = 0
  for linenr, text in ipairs(lines) do
    for i, item in ipairs(vim.b.filter_patterns) do
      local start_col = 1
      local inserted = false
      local pattern = item[1]
      local hl_group = item[2]
      while true do
        -- string.find returns byte‐indices; convert to 0‐based
        local s, e = string.find(text, pattern, start_col)
        if not s then break end

        if not inserted then
          api.nvim_buf_set_lines(scratch_buf, inserted_count, inserted_count + 1, false, {text})
          inserted_count = inserted_count + 1
          inserted = true
	  api.nvim_buf_add_highlight(scratch_buf, M.ns, hl_group, inserted_count - 1, 0, -1)
        end

        -- highlight group “MyPluginMatch” must be defined elsewhere
        api.nvim_buf_add_highlight(scratch_buf, M.ns, "TextFilterHighlightGroupKey",
          inserted_count - 1, s - 1, e)

        -- continue search just after this match
        start_col = e + 1
      end
    end
  end

  local win = api.nvim_open_win(scratch_buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    row = math.floor(vim.o.lines * 0.1),
    col = math.floor(vim.o.columns * 0.1),
    style = "minimal", border = "single"
  })
  api.nvim_win_set_hl_ns(win, M.ns)
end

--- Highlight all lines matching `pattern` in the current buffer.
-- @param pattern string  Lua pattern to match (e.g. "TODO")
function M.highlight(pattern)
  local buf = api.nvim_get_current_buf()
  -- clear previous highlights
  api.nvim_buf_clear_namespace(buf, state.ns, 0, -1)
  -- scan each line
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:match(pattern) then
      api.nvim_buf_add_highlight(buf, M.ns, "TextFilterHighlightGroup", i - 1, 0, -1)
    end
  end
end

M.ns = api.nvim_create_namespace("myplugin.annotations")

-- Setup function: define user commands and maps
function M.setup()
  api.nvim_set_hl(M.ns, "TextFilterHighlightGroupGreen", {
    fg        = "#0000F7",    -- GUI foreground (hex)
    bg        = "#008F00",    -- GUI background (hex)
    ctermfg   = 7,          -- 256-color CTerm fg
    ctermbg   = 2,          -- 256-color CTerm bg
  })
  api.nvim_set_hl(M.ns, "TextFilterHighlightGroupBlue", {
    fg        = "#F7F700",    -- GUI foreground (hex)
    bg        = "#00008F",    -- GUI background (hex)
    ctermfg   = 7,          -- 256-color CTerm fg
    ctermbg   = 4,          -- 256-color CTerm bg
  })
  api.nvim_set_hl(M.ns, "TextFilterHighlightGroupKey", {
    bold      = true;
    underline = true;
  })
  -- :HideLines <start> <end>
  api.nvim_create_user_command("HideLines", function(opts)
    local s, e = tonumber(opts.fargs[1]), tonumber(opts.fargs[2])
    M.hide_range(s, e)
  end, { nargs = '*', desc = "Fold (hide) lines from START to END" })

  -- :UnhideLines <start>
  api.nvim_create_user_command("UnhideLines", function(opts)
    local s = tonumber(opts.fargs[1])
    M.unhide_range(s)
  end, { desc = "Open (show) fold at line START" })

  -- :ToggleFold <start> <end>
  api.nvim_create_user_command("ToggleFold", function(opts)
    local s, e = tonumber(opts.fargs[1]), tonumber(opts.fargs[2])
    M.toggle_range(s, e)
  end, { desc = "Toggle fold (hide/show) between START and END" })

  -- Example keymap: <leader>h to prompt and hide
  vim.keymap.set("n", "<leader>h", function()
    local s = tonumber(vim.fn.input("Hide from line: "))
    local e = tonumber(vim.fn.input("Hide to line: "))
    if s and e then M.hide_range(s, e) end
  end, { desc = "Prompt for a line range and hide it" })

  api.nvim_create_user_command("Filter",
    function(opts) M.filter(opts.args) end,
    { nargs = 1, desc = "Filter out lines matching PATTERN" }
  )
  api.nvim_create_user_command("FilterBuf",
    function(opts) M.filter_to_new_buf(opts.args) end,
    { nargs = 1, desc = "Filter out lines matching PATTERN" }
  )
  api.nvim_create_user_command("FilterSavedBuf",
    function(opts) M.filter_by_saved_patterns() end,
    { nargs = 0, desc = "Filter out lines using saved patterns" }
  )
  api.nvim_create_user_command("AddPattern",
    function(opts) M.add_filter_pattern(opts.fargs[1], opts.fargs[2]) end,
    { nargs = '*', desc = "Add a pattern for highlight and filter" }
  )
  api.nvim_create_user_command("Unfilter",
    function() M.unfilter() end,
    { nargs = 0, desc = "Restore filtered lines" }
  )
  api.nvim_buf_create_user_command(0, "HighlightMatch",
    function(opts) M.highlight(opts.args) end,
    { nargs = 1, desc   = "Highlight lines matching the given Lua PATTERN" }
  )
end

return M
