local api = vim.api
local Nibbler = {}

local function get_word_under_cursor()
  local cword = vim.fn.expand('<cword>')
  return cword
end

return Nibbler
