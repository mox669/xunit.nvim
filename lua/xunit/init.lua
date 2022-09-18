local gather = require("xunit.gather")
local run = require("xunit.run")

local api = vim.api
local cmd = vim.api.nvim_create_user_command
local bufnr = vim.api.nvim_get_current_buf()
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

local function inspect_data()
	print("Current namespace -> " .. gather.xunit_globs.namespace)
	print("Classname         -> " .. gather.xunit_globs.classname)
	print("\n")
	print("+-------------------------TESTS-------------------------+\n")
	for _, test in pairs(gather.xunit_globs.tests) do
		print("TEST: " .. test.name .. " at line " .. test.line)
		print("Range -> ", vim.inspect(test.meta[1].range))
		print("\n")
	end
end

local function setup_autocmd()
	api.nvim_create_autocmd("BufRead", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			gather.gather(bufnr)
		end,
	})

	api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			gather.gather(bufnr)
		end,
	})
end

local function setup_cmd()
	cmd("XShowTests", function()
		inspect_data()
	end, {})

	cmd("XRunAll", function()
		run.execute_all(gather.xunit_globs)
	end, {})
end

function M.setup()
	setup_autocmd()
	setup_cmd()
end

return M
