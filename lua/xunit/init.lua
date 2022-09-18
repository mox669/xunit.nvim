local gather = require("xunit.gather")

local api = vim.api
local cmd = vim.api.nvim_create_user_command
local bufnr = vim.api.nvim_get_current_buf()
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

local function inspect_data()
	print("Current namespace -> " .. gather.data.namespace)
	print("Classname -> " .. gather.data.classname)
	print("\n+----------------TESTS----------------+\n")
	for _, test in pairs(gather.data.tests) do
		print("TEST: " .. test.name .. "at line " .. test.line)
		print("Range -> ", vim.inspect(test.meta[1].range[1]))
	end
end

local function setup_autocmd()
	api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			gather.gather(bufnr)
		end,
	})
end

local function setup_cmd()
	cmd("XInspect", function()
		inspect_data()
	end, {})
end

function M.setup()
	setup_autocmd()
	setup_cmd()
end

return M
