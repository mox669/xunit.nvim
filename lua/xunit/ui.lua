local M = {}
local api = vim.api

function M.set_virt_all(bufnr, ns, tests, virt_text)
	for k, test in pairs(tests) do
		M.set_virt(bufnr, ns, test, k, virt_text)
	end
end

function M.set_virt(bufnr, ns, test, k, virt_text)
	-- delete previous extmarks with given id
	vim.api.nvim_buf_del_extmark(bufnr, ns, k)
	-- create extmark
	vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, {
		id = k,
		--TODO (olekatpyle)  09/18/22 - 12:36: add custom HL-Group
		virt_text = { { virt_text, "" } },
		virt_text_pos = "eol",
		ui_watched = true,
	})
end

function M.create_window()
	vim.cmd("split")
	M.buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	-- get dimensions
	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	-- calculate our floating window size
	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)

	-- and its starting position
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	-- set some options
	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	-- and finally create it with buffer attached
	M.win = api.nvim_open_win(buf, true, opts)
end

return M
