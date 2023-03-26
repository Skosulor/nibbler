local api = vim.api
local Nibbler = {}

local function get_word_under_cursor()
  local cword = vim.fn.expand('<cword>')
  return cword
end

local function replace_word_under_cursor(new_word)
  local current_line = api.nvim_get_current_line()
  local old_word = vim.fn.expand('<cword>')
  local replaced_line = vim.fn.substitute(current_line, old_word, new_word, '')
  api.nvim_set_current_line(replaced_line)
end

function Nibbler.convert_to_hex()
return Nibbler
