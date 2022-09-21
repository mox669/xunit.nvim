----
-- xunit.ui
-- Handles windows and extmarks.
-- Global table that stores current selected test for current buffer.
----
local M = {}
local api = vim.api
local popup = require("plenary.popup")
local u = require("xunit.utils")
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")

Xwin_id = nil
Xbufnr = nil
Xlwin_id = nil
Xlbufnr = nil
Xlborder = nil
-- local u = require("xunit.utils")

-- init the current selected test for the buffer with 0
M.ui_globs = {}
function M.init_ui()
	local bufnr = api.nvim_get_current_buf()
	local globs = { current = 0 }
	M.ui_globs[bufnr] = globs
end

function M.set_ext_all(bufnr, ns, tests, virt_text, hl)
	M.del_all_ext(bufnr)
	for _, test in pairs(tests) do
		M.set_ext(bufnr, ns, test.line, test.id, virt_text, hl)
	end
end

function M.set_ext(bufnr, ns, line, i, virt_text, hl)
	-- delete previous extmarks with given id
	vim.api.nvim_buf_del_extmark(bufnr, ns, i)

	-- create extmark
	vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
		id = i,
		virt_text = { { virt_text, hl } },
		virt_text_pos = "eol",
		ui_watched = true,
	})
end

function M.del_all_ext(bufnr)
	local ns = require("xunit.gather").xunit_globs[bufnr].marks_ns
	local marks = api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
	for _, m in pairs(marks) do
		api.nvim_buf_del_extmark(bufnr, ns, m[1])
	end
end

local function center_text(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

local function open_window()
	local bufnr = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

	local conf = config.get()

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.9 - 4)
	local win_width = math.ceil(width * 0.95)

	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

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

	local border = conf.border
	local border_buf = api.nvim_create_buf(false, true)
	local border_lines = { border[1] .. string.rep(border[2], win_width) .. border[3] }
	local middle_line = border[#border] .. string.rep(" ", win_width) .. border[#border]
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, border[4] .. string.rep(border[2], win_width) .. border[5])

	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	local win = api.nvim_open_win(bufnr, true, opts)

	return {
		win_id = win,
		bufnr = bufnr,
		border_buf = border_buf,
	}
end

local function close(menu)
	if menu then
		api.nvim_win_close(Xwin_id, true)
		Xwin_id = nil
	else
		api.nvim_win_close(Xlwin_id, true)
		api.nvim_buf_delete(Xlborder, {})
		Xlwin_id = nil
	end
end

local function open_menu()
	local conf = config.get()
	local bufnr = vim.api.nvim_create_buf(false, false)
	local width = 60
	local height = 10
	local border = conf.border
	local borderchars = {
		border[2],
		border[#border],
		border[2],
		border[#border],
		border[1],
		border[3],
		border[5],
		border[4],
	}
	local Xwin_id, win = popup.create(bufnr, {
		title = "Tests",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	return {
		bufnr = bufnr,
		win_id = Xwin_id,
	}
end

function M.toggle_test_log(log)
	if Xlwin_id ~= nil and vim.api.nvim_win_is_valid(Xlwin_id) then
		close(false)
		return
	end

	local win_info = open_window()
	Xlwin_id = win_info.win_id
	Xlbufnr = win_info.bufnr
	Xlborder = win_info.border_buf
	api.nvim_buf_set_option(Xlbufnr, "modifiable", true)
	vim.api.nvim_buf_set_option(Xlbufnr, "bufhidden", "delete")
	vim.api.nvim_buf_set_option(Xlbufnr, "buftype", "acwrite")
	vim.api.nvim_buf_set_name(Xlbufnr, "Testlog")
	api.nvim_buf_set_lines(Xlbufnr, 0, -1, false, {
		center_text("TEST RESULT"),
	})
	api.nvim_buf_set_lines(Xlbufnr, 1, -1, false, {
		center_text("---------------"),
	})
	api.nvim_buf_set_lines(Xlbufnr, 3, #log, false, log)
	api.nvim_buf_set_option(Xlbufnr, "modifiable", false)
end

function M.toggle_quick_menu()
	if Xwin_id ~= nil and vim.api.nvim_win_is_valid(Xwin_id) then
		close(true)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local win_info = open_menu()

	Xwin_id = win_info.win_id
	Xbufnr = win_info.bufnr

	local win_width = api.nvim_win_get_width(Xwin_id)

	local contents = {
		"Namespace ->" .. globs.namespace,
		"Class     -> " .. globs.classname,
		string.rep("-", win_width),
		"",
	}

	local pre
	for _, test in pairs(globs.tests) do
		if test.fact then
			pre = "[FACT]   "
		else
			pre = "[THEORY] "
		end
		table.insert(contents, pre .. test.name .. " at line " .. test.line)
	end

	vim.api.nvim_buf_set_name(Xbufnr, "Tests")
	vim.api.nvim_buf_set_lines(Xbufnr, 0, #contents, false, contents)
	api.nvim_buf_set_option(Xbufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(Xbufnr, "filetype", "harpoon")
	vim.api.nvim_buf_set_option(Xbufnr, "buftype", "acwrite")
	vim.api.nvim_buf_set_option(Xbufnr, "bufhidden", "delete")
	vim.api.nvim_win_set_cursor(0, { 5, 0 })
	vim.api.nvim_buf_set_keymap(Xbufnr, "n", "<CR>", "<Cmd>lua require('xunit.ui').select_menu_item()<CR>", {})
end

function M.select_menu_item()
	local idx = vim.fn.line(".") - 4
	local crow = api.nvim_win_get_cursor(Xwin_id)[1]
	-- check if cursor is at pos of test
	if crow >= 5 then
		close(true)
		M.jumpto(idx)
	end
end

function M.jumpto(id)
	local bufnr = api.nvim_get_current_buf()
	local test = require("xunit.gather").xunit_globs[bufnr].tests[id]
	local row = test.line
	local col = test.offset[2]
	M.ui_globs[bufnr].current = id
	vim.api.nvim_win_set_cursor(0, { row + 2, col })
end

return M
