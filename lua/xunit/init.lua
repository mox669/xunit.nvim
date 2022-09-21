----
-- xunit.init
-- Entry point
----

local config = require("xunit.config")
local gather = require("xunit.gather")
local ui = require("xunit.ui")
local u = require("xunit.utils")
local run = require("xunit.run")
local ctrl = require("xunit.controls")

local api = vim.api
local cmd = vim.api.nvim_create_user_command
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

local function inspect_data()
	local buf = api.nvim_get_current_buf()
	-- u.debug(buf)
	-- u.debug(gather.xunit_globs)
	print("Current namespace -> " .. gather.xunit_globs[buf].namespace)
	print("Classname         -> " .. gather.xunit_globs[buf].classname)
	print("\n")
	print("+-------------------------TESTS-------------------------+\n")
	for _, test in pairs(gather.xunit_globs[buf].tests) do
		print("TEST: " .. test.name .. " at line " .. test.line)
		print("Range -> ", vim.inspect(test.offset))
		print("\n")
	end
end

local function setup_autocmd()
	api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			gather.gather()
			ui.init_ui()
		end,
	})

	api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			gather.gather()
		end,
	})
end

local function setup_cmd()
	cmd("XShowTests", function()
		inspect_data()
	end, {})

	cmd("XRunAll", function()
		run.execute_all()
	end, {})

	cmd("XRunTest", function()
		run.execute_test()
	end, {})

	cmd("XShowResult", function()
		run.show_test_result()
	end, {})

	cmd("XNextTest", function()
		ctrl.jumpto_next()
	end, {})

	cmd("XPrevTest", function()
		ctrl.jumpto_prev()
	end, {})
	-- cmd("XDebug", function()
	-- 	ui.del_all_ext()
	-- end, {})
end

function M.setup(conf)
	config.set(conf)
	setup_autocmd()
	setup_cmd()
end

return M
