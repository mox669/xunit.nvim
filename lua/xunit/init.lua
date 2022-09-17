local gather = require("xunit.gather")
local bufnr = vim.api.nvim_get_current_buf()
local data = {}
local M = {}

vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("xunit-test", { clear = true }),
	pattern = "*.cs",
	callback = gather.gather(bufnr, data),
})

function M.XInspect()
	print(vim.inspect(data.namespace))
	print(vim.inspect(data.classname))
	print("TESTS")
	for _, test in data.tests do
		print("Name:" .. vim.inspect(test[1]))
		print("Line:" .. vim.inspect(test[2]))
		print("Meta:" .. vim.inspect(test[3]))
	end
end

return M
