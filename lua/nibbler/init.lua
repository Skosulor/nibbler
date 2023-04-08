local api = vim.api
local ns_id = api.nvim_create_namespace('nibbler')

local M = {}
local display_enabled = true

local function parse_number(word)
    local number, base

    if string.match(word, '^0b') then
        number = tonumber(word:sub(3), 2)
        base = 'bin'
    elseif string.match(word, '^0x') then
        number = tonumber(word, 16)
        base = 'hex'
    else
        number = tonumber(word)
        base = 'dec'
    end

    return number, base
end

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
        local number, _ = parse_number(word)
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

local function display_decimal_representation()
    if not display_enabled then
        return
    end

    local cword = vim.fn.expand('<cword>')
    local number, base = parse_number(cword)

    if number and not string.match(base, 'dec') then
        local cursor_pos = api.nvim_win_get_cursor(0)
        local row, _ = cursor_pos[1] - 1, cursor_pos[2]
        clear_virtual_text()
        api.nvim_buf_set_virtual_text(0, ns_id, row, { { tostring(number), 'Comment' } }, {})
    else
        clear_virtual_text()
    end
end

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

    local cursor_pos = vim.fn.getcurpos()
    local cursor_line, cursor_col = cursor_pos[2], cursor_pos[3]

    -- Check if there is no selection
    if first_line == last_line and start_pos[3] == end_pos[3] and first_line == cursor_line and start_pos[3] == cursor_col then
        local word = get_word_under_cursor()
        if word then
            local number, _ = parse_number(word)
            if number then
                if toggle then
                    toggle_base()
                else
                    replace_word_under_cursor(convert_number_to_base(number, target_base))
                end
            end
        end
    else
        for line_number = first_line, last_line do
            local current_line = api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
            local words = vim.fn.split(current_line, '\\s\\+')

            for i, word in ipairs(words) do
                local number, _ = parse_number(word)
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
            api.nvim_buf_set_lines(0, line_number - 1, line_number, false, { new_line })
        end
    end
end

local function hexstring_to_c_arrray(args)
    local edits = require("nibbler.edits")
    local text = nil
    local range = nil
    if args.range == 0 then
        text = edits.get_word_under_cursor()
        range = edits.get_word_under_cursor_range()
    elseif args.range == 2 then
        text = edits.get_selected_text()
        range = edits.get_selected_range()
    end
    edits.replace_range_with(range, text:gsub("%x%x", "0x%1, "):sub(1, -3))
end


function M.setup(opts)
    if opts and opts.display_enabled ~= nil then
        display_enabled = opts.display_enabled
    end

    api.nvim_create_user_command("NibblerToggle", function() convert_selected_base(nil, true) end, {
        nargs = '?',
        range = true,
        desc = "Toggles between binary, decimal, and hexadecimal representations",
    })
    api.nvim_create_user_command("NibblerToHex", function() convert_selected_base('hex', false) end, {
        nargs = '?',
        range = true,
        desc = "Converts a number to its hexadecimal representation"
    })
    api.nvim_create_user_command("NibblerToBin", function() convert_selected_base('bin', false) end, {
        nargs = '?',
        range = true,
        desc = "Converts a number to its binary representation"
    })
    api.nvim_create_user_command("NibblerToDec", function() convert_selected_base('dec', false) end, {
        nargs = '?',
        range = true,
        desc = "Converts a number to its decimal representation"
    })
    api.nvim_create_user_command("NibblerToggleDisplay", toggle_real_time_display, {
        nargs = '?',
        desc = "Toggle virtual text showing decimal value of hex or bin number"
    })
    api.nvim_create_user_command("NibblerHexStringToCArray", hexstring_to_c_arrray, {
        range = true,
        desc = "Converts a hexadecimal string to a C-style array",
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = api.nvim_create_augroup("NibblerDecimalRepresentation", { clear = true }),
        callback = display_decimal_representation
    })
end

return M
