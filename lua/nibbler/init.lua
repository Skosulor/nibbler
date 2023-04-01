local api = vim.api
local ns_id = api.nvim_create_namespace('nibbler')

local M = {}
local display_enabled = true

local function get_word_under_cursor()
    return vim.fn.expand('<cword>')
end

local function replace_word_under_cursor(new_word)
    local current_line = api.nvim_get_current_line()
    local old_word = vim.fn.expand('<cword>')
    local replaced_line = vim.fn.substitute(current_line, old_word, new_word, '')
    api.nvim_set_current_line(replaced_line)
end

local function to_binary(number)
    local binary = ""
    while number > 0 do
        binary = (number % 2) .. binary
        number = math.floor(number / 2)
    end
    return '0b' .. binary
end

local function convert_number_to_base(number, base)
    if base == 'hex' then
        return string.format('%#x', number)
    elseif base == 'bin' then
        return to_binary(number)
    elseif base == 'dec' then
        return tostring(number)
    end
end

local function toggle_base()
    local word = get_word_under_cursor()
    if word then
        local number
        if string.match(word, '^0b') then
            number = tonumber(word:sub(3), 2)
        elseif string.match(word, '^0x') then
            number = tonumber(word, 16)
        else
            number = tonumber(word)
        end

        if number then
            if string.match(word, '^0b') then
                replace_word_under_cursor(tostring(number))
            elseif string.match(word, '^0x') then
                replace_word_under_cursor(to_binary(number))
            else
                replace_word_under_cursor(string.format('%#x', number))
            end
        end
    end
end

local function clear_virtual_text()
    api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

function display_decimal_representation()
    if not display_enabled then
        return
    end

    local cword = vim.fn.expand('<cword>')
    local number

    if string.match(cword, '^0b') then
        number = tonumber(cword:sub(3), 2)
    elseif string.match(cword, '^0x') then
        number = tonumber(cword, 16)
    end

    if number then
        local cursor_pos = api.nvim_win_get_cursor(0)
        local row, _ = cursor_pos[1] - 1, cursor_pos[2]
        clear_virtual_text()
        api.nvim_buf_set_virtual_text(0, ns_id, row, { { tostring(number), 'Comment' } }, {})
    else
        clear_virtual_text()
    end
end

vim.cmd([[
augroup NibblerDecimalRepresentation
autocmd!
autocmd CursorMoved * lua display_decimal_representation()
autocmd CursorMovedI * lua display_decimal_representation()
augroup END
]])

local function toggle_real_time_display()
    display_enabled = not display_enabled
    if not display_enabled then
        clear_virtual_text()
    end
end


local function convert_selected_base(target_base, toggle)
    vim.cmd('normal! v:leave')
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local first_line, last_line = start_pos[2], end_pos[2]

    if first_line == last_line and start_pos[3] == end_pos[3] then
        toggle_base()
    else
        for line_number = first_line, last_line do
            local current_line = api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local words = vim.fn.split(current_line, '\\s\\+')

            for i, word in ipairs(words) do
                local number
                if string.match(word, '^0b') then
                    number = tonumber(word:sub(3), 2)
                elseif string.match(word, '^0x') then
                    number = tonumber(word, 16)
                else
                    number = tonumber(word)
                end

                if number then
                    if toggle then
                        if string.match(word, '^0b') then
                            words[i] = tostring(number)
                        elseif string.match(word, '^0x') then
                            words[i] = to_binary(number)
                        else
                            words[i] = string.format('%#x', number)
                        end
                    else
                        words[i] = convert_number_to_base(number, target_base)
                    end
                end
            end

            local new_line = table.concat(words, ' ')
            api.nvim_buf_set_lines(0, line_number - 1, line_number, false, {new_line})
        end
    end
end

api.nvim_create_user_command("NibblerToggle", function() convert_selected_base(nil, true) end, { nargs='?', range=true })
api.nvim_create_user_command("NibblerToHex", function() convert_selected_base('hex', false) end, { nargs='?', range=true })
api.nvim_create_user_command("NibblerToBin", function() convert_selected_base('bin', false) end, { nargs='?', range=true })
api.nvim_create_user_command("NibblerToDec", function() convert_selected_base('dec', false) end, { nargs='?', range=true })
api.nvim_create_user_command("NibblerToggleDisplay", toggle_real_time_display, { nargs='?' })

function M.setup(opts)
    if opts and opts.display_enabled ~= nil then
        display_enabled = opts.display_enabled
    end
end

return M

