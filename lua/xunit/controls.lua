----
-- xunit.controls
-- Handles cursor movement to jump between tests
----
local M = {}
local api = vim.api

function M.jumpto_next()
	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local uglobs = require("xunit.ui").ui_globs[bufnr]
	local current = uglobs.current

	if current == #globs.tests or current == 0 then
		uglobs.current = 1
	else
		uglobs.current = current % #globs.tests + 1
	end

	local test = globs.tests[uglobs.current]
	local row = test.line
	local col = test.offset[2]

	vim.api.nvim_win_set_cursor(0, { row + 2, col })
end

function M.jumpto_prev()
	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local uglobs = require("xunit.ui").ui_globs[bufnr]
	local current = uglobs.current

	if current <= 1 then
		uglobs.current = #globs.tests
	else
		uglobs.current = (current - 1) % #globs.tests
	end

	local test = globs.tests[uglobs.current]
	local row = test.line
	local col = test.offset[2]

	vim.api.nvim_win_set_cursor(0, { row + 2, col })
end

return M
