---@class Bounce
local M = {}

local marks = {}
local update_timer = vim.loop.new_timer()
local namespace = vim.api.nvim_create_namespace("bounce")
local config = { highlight_group_name = "@text.todo", delay_time = 1000, more_jumps = false, display_mode = "overlay" }

local function find_jump_points(forward, jump_table)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local word_count = 1
  while true do
    if forward then
      vim.api.nvim_command("norm! w")
    else
      vim.api.nvim_command("norm! b")
    end
    local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))
    if current_row ~= row or current_col >= string.len(line) or string.len(line) == 0 then
      break
    end
    if not config.more_jumps and word_count > 9 then
      break
    end
    if #jump_table > 0 and jump_table[#jump_table].pos == current_col then
      break
    end
    table.insert(jump_table, {
      line = current_row - 1,
      pos = current_col,
      char = line:sub(current_col + 1, current_col + 1),
      count = word_count % 10,
    })
    word_count = word_count + 1
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
  return jump_table
end

local function replace_char(str, n, ch)
  return string.sub(str, 0, n) .. ch .. string.sub(str, n + 2, string.len(str))
end

local function sort_by_pos(a, b)
  return a.pos < b.pos
end

local function assemble_virtual_line(jump_table)
  local win = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local max_width = win.width - win.textoff
  local line_table = {}
  table.sort(jump_table, sort_by_pos)
  local n = 0
  local line = string.rep(" ", max_width)
  local extended_line = string.rep(" ", string.len(vim.api.nvim_get_current_line()))
  if #jump_table > 0 then
    for i = 1, #jump_table do
      extended_line = replace_char(extended_line, jump_table[i].pos, jump_table[i].count)
    end
    local cut_start = 0
    while true do
      local cut_end = max_width * (n + 1)
      if n > 0 then
        cut_end = cut_end - jump_table[1].pos
      end
      if cut_end > string.len(extended_line) then
        cut_end = string.len(extended_line)
      end
      local cut_line = string.sub(extended_line, cut_start, cut_end)
      if n > 0 then
        cut_line = string.rep(" ", jump_table[1].pos) .. cut_line
      end
      table.insert(line_table, cut_line)
      if max_width * (n + 1) > string.len(extended_line) then
        break
      end
      n = n + 1
      cut_start = cut_end + 1
    end
  end
  return line_table
end

local function update_word_buffer()
  local temp_words = {}
  find_jump_points(true, temp_words)
  find_jump_points(false, temp_words)
  if config.display_mode == "overlay" then
    if #temp_words > 0 then
      for i = 1, #temp_words do
        local mark = vim.api.nvim_buf_set_extmark(0, namespace, temp_words[i].line, temp_words[i].pos, {
          virt_text = { { tostring(temp_words[i].count), config.highlight_group_name } },
          virt_text_pos = "overlay",
          virt_text_hide = true,
          hl_mode = "replace",
        })
        table.insert(marks, mark)
      end
    end
  elseif config.display_mode == "virtual_line" then
    local lines = assemble_virtual_line(temp_words)
    if #lines > 0 then
      for i = 1, #lines do
        local mark = vim.api.nvim_buf_set_extmark(0, namespace, temp_words[1].line, i, {
          hl_mode = "replace",
          virt_lines = { { { lines[i], config.highlight_group_name } } },
        })
        table.insert(marks, mark)
      end
    end
  end
end

local function hide_word_numbers()
  update_timer:stop()
  for i = 1, #marks do
    vim.api.nvim_buf_del_extmark(0, namespace, marks[i])
  end
  marks = {}
end

local function show_word_numbers()
  hide_word_numbers()
  update_timer:start(config.delay_time, 0, vim.schedule_wrap(update_word_buffer))
end

local function setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  vim.api.nvim_create_autocmd({ "CursorMoved" }, { callback = show_word_numbers })
  vim.api.nvim_create_autocmd(
    { "ModeChanged", "CmdlineEnter", "WinResized", "VimResized" },
    { callback = hide_word_numbers }
  )
end

M = {
  setup = setup,
  show_word_numbers = show_word_numbers,
  hide_word_numbers = hide_word_numbers,
}

return M
