local gather = require("xunit.gather")
local bufnr = vim.api.nvim_get_current_buf()

local api = vim.api
local cmd = vim.api.nvim_create_user_command

local data = {}
local M = {}

api.nvim_create_autocmd("BufEnter", {
	group = api.nvim_create_augroup("xunit-test", { clear = true }),
	pattern = "*.cs",
	callback = gather.gather(bufnr, data),
})

function M.inspect_data()
	print(vim.inspect(data.namespace))
	print(vim.inspect(data.classname))
	print("TESTS")
	for _, test in data.tests do
		print("Name:" .. vim.inspect(test[1]))
		print("Line:" .. vim.inspect(test[2]))
		print("Meta:" .. vim.inspect(test[3]))
	end
end

cmd("XInspect", function()
	M.inspect_data()
end, {})

return M
