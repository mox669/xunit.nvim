local gather = require("xunit.gather")

local api = vim.api
local cmd = vim.api.nvim_create_user_command
local bufnr = vim.api.nvim_get_current_buf()
local augroup = api.nvim_create_augroup("xunit-test", { clear = true })

local M = {}

local function inspect_data()
	print(gather.glob.namespace)
	print(gather.glob.classname)
	print("TESTS")
	for _, test in gather.tests do
		print(test.name .. " at line " .. test.line)
		-- print("Meta:" .. print(getmetatable(test[3])))
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
