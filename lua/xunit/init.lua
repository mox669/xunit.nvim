local api = vim.api
local cmd = vim.api.nvim_create_user_command
local bufnr = vim.api.nvim_get_current_buf()
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

local function inspect_data()
	local gather = require("xunit.gather")
	local data = gather.data
	print(data.namespace)
	print(data.classname)
	print("TESTS")
	for _, test in data.tests do
		print("Name:" .. print(test.name))
		print("Line:" .. print(test.line))
		-- print("Meta:" .. print(getmetatable(test[3])))
	end
end

local function setup_autocmd()
	api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		pattern = "*.cs",
		callback = function()
			require("xunit.gather").gather(bufnr)
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
