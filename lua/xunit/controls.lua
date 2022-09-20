local M = {}
local api = vim.api

-- function M.jumpto_first()
-- 	local bufnr = api.nvim_get_current_buf()
-- 	local globs = require("xunit.gather").xunit_globs[bufnr]
-- 	local test = globs.tests[1]
-- 	local row = test.line
-- 	local col = test.offset[2]
-- 	-- u.debug(test)
-- 	-- u.debug(globs.tests[1].meta[1].range)
-- 	-- u.debug(row)
-- 	-- u.debug(col)

-- 	vim.api.nvim_win_set_cursor(0, { row + 1, col })
-- 	globs.current = 1
-- end

function M.jumpto_next()
	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local current = globs.current

	if current == #globs.tests or current == 0 then
		globs.current = 1
	else
		globs.current = current % #globs.tests + 1
	end

	local test = globs.tests[globs.current]
	local row = test.line
	local col = test.offset[2]

	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

function M.jumpto_prev()
	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local current = globs.current

	if current <= 1 then
		globs.current = #globs.tests
	else
		globs.current = (current - 1) % #globs.tests
	end

	local test = globs.tests[globs.current]
	local row = test.line
	local col = test.offset[2]

	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

return M
