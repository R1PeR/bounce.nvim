---@class Bounce
local M = {}

local words = {}
local update_timer = vim.loop.new_timer()
local namespace = vim.api.nvim_create_namespace("bounce")
local config = { hightlight_group_name = '@text.todo', delay_time = 1000 }

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
    if current_row ~= row or word_count > 9 or current_col >= string.len(line) or string.len(line) == 0 then
      break
    end
    table.insert(jump_table, {
      line = current_row - 1,
      pos = current_col,
      char = line:sub(current_col + 1, current_col + 1),
      count = word_count,
    })
    word_count = word_count + 1
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
  return jump_table
end

local function update_word_buffer()
  find_jump_points(true, words)
  find_jump_points(false, words)
  for i = 1, #words do
    words[i].mark = vim.api.nvim_buf_set_extmark(0, namespace, words[i].line, words[i].pos, {
      virt_text = { { tostring(words[i].count), config.highlight_group_name } },
      virt_text_pos = "overlay",
      virt_text_hide = true,
      -- hl_group = config.hightlight_group_name,
      hl_mode = "replace",
    })
  end
end

local function hide_word_numbers()
  update_timer:stop()
  for i = 1, #words do
    vim.api.nvim_buf_del_extmark(0, namespace, words[i].mark)
  end
  words = {}
end

local function show_word_numbers()
  hide_word_numbers()
  update_timer:start(config.delay_time, 0, vim.schedule_wrap(update_word_buffer))
end

local function setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  print("bounce config:", config.highlight_group_name, config.delay_time)
  vim.api.nvim_create_autocmd({ "CursorMoved" }, { callback = show_word_numbers })
  vim.api.nvim_create_autocmd({ "ModeChanged", "CmdlineEnter" }, { callback = hide_word_numbers })
end

M = {
  setup = setup,
  show_word_numbers = show_word_numbers,
  hide_word_numbers = hide_word_numbers,
}

return M
