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
  local word = get_word_under_cursor()
  if word then
    local number = tonumber(word)
    if number then
      local hex_number = string.format('%#x', number)
      replace_word_under_cursor(hex_number)
    else
    end
  else
  end
end

local function to_binary(number)
  local binary = ""
  while number > 0 do
    binary = (number % 2) .. binary
    number = math.floor(number / 2)
  end
  return '0b' .. binary
end

function Nibbler.convert_to_binary()
  local word = get_word_under_cursor()
  if word then
    local number = tonumber(word)
    if number then
      local binary_number = to_binary(number)
      replace_word_under_cursor(binary_number)
    end
  end
end
return Nibbler

