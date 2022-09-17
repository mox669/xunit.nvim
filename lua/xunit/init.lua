local gather = require("xunit.gather")

local api = vim.api
local cmd = vim.api.nvim_create_user_command
local bufnr = vim.api.nvim_get_current_buf()
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

function M.inspect_data()
	print(vim.inspect(data.namespace))
	print(vim.inspect(data.classname))
	print("TESTS")
	for _, test in data.tests do
		print("Name:" .. vim.inspect(test[1]))
		print("Line:" .. vim.inspect(test[2]))
		print("Meta:" .. getmetatable(test[3]))
	end
end

local function setup_autocmd()
	api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			data = gather.gather(bufnr)
		end,
	})
end

local function setup_cmd()
	cmd("XInspect", function()
		M.inspect_data()
	end, {})
end

function M.setup()
	setup_autocmd()
	setup_cmd()
end

return M
