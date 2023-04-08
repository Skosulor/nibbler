local M = {}

function M.get_selected_range()
    return {
        start_row = vim.fn.line("'<"),
        start_col = vim.fn.col("'<"),
        end_row = vim.fn.line("'>"),
        end_col = vim.fn.col("'>"),
    }
end

function M.get_word_under_cursor_range()
    local current_line_index, current_column_index = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.fn.getline('.')
    local _, cword_start, cword_end = unpack(vim.fn.matchstrpos(line,
        [[\k*\%]] .. current_column_index + 1 .. [[c\k*]]))

    return {
        start_row = current_line_index,
        start_col = cword_start + 1,
        end_row = current_line_index,
        end_col = cword_end
    }
end

function M.get_selected_lines()
    local range = M.get_selected_range()
    local text = vim.api.nvim_buf_get_lines(0, range.start_row - 1, range.end_row, false)
    local text_length = #text
    local end_col = math.min(#text[text_length], range.end_col)
    local end_idx = vim.str_byteindex(text[text_length], end_col)
    local start_idx = vim.str_byteindex(text[1], range.start_col)

    text[text_length] = text[text_length]:sub(1, end_idx)
    text[1] = text[1]:sub(start_idx or 0)

    return text
end

function M.get_selected_text()
    local selected_lines = M.get_selected_lines()
    return table.concat(selected_lines, "\n")
end

function M.get_word_under_cursor()
    return vim.fn.expand("<cword>")
end

function M.replace_range_with(range, to_insert)
    if type(to_insert) == "table" then
        to_insert = table.concat(to_insert, "\n")
    end
    local edits = {
        {
            range = {
                ["start"] = {
                    line = range.start_row - 1,
                    character = range.start_col - 1,
                },
                ["end"] = {
                    line = range.end_row - 1,
                    character = range.end_col,
                },
            },
            newText = to_insert
        }
    }
    vim.lsp.util.apply_text_edits(edits, 0, "utf-16")
end

function M.replace_selection_with(to_insert)
    M.replace_range_with(M.get_selected_range(), to_insert)
end

function M.replace_word_under_cursor_with(to_insert)
    M.replace_range_with(M.get_word_under_cursor_range(), to_insert)
end

return M
