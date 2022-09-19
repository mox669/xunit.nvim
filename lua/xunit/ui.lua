local M = {}
local api = vim.api
local u = require("xunit.utils")

function M.set_ext_all(bufnr, ns, tests, virt_text, hl)
	for k, test in pairs(tests) do
		M.set_ext(bufnr, ns, test.line, k, virt_text, hl)
	end
end

function M.set_ext(bufnr, ns, line, k, virt_text, hl)
	-- delete previous extmarks with given id
	vim.api.nvim_buf_del_extmark(bufnr, ns, k)
	-- create extmark
	vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
		id = k,
		--TODO (olekatpyle)  09/18/22 - 12:36: add custom HL-Group
		virt_text = { { virt_text, hl } },
		virt_text_pos = "eol",
		ui_watched = true,
	})
end

function M.center_text(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

local win, buf
function M.create_window()
	buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	api.nvim_buf_add_highlight(buf, -1, "VirtFloatNormal", 0, 0, -1)
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local border_buf = api.nvim_create_buf(false, true)

	local border_lines = { "╔" .. string.rep("═", win_width) .. "╗" }
	local middle_line = "║" .. string.rep(" ", win_width) .. "║"
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, "╚" .. string.rep("═", win_width) .. "╝")

	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	return buf
end

return M
