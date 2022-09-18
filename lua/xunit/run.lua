local M = {}

local api = vim.api
local config = require("xunit.config")
local ui = require("xunit.ui")

local function analyze(data)
	print(vim.inspect(data))
	--TODO (olekatpyle)  09/18/22 - 17:32: find a smoother way to check if success?
	for _, line in ipairs(data) do
		if line[1].find(line[1], "Fehler!") or line[1].find(line[1], "Failed!") then
			return false
		end
	end
	return true
end

local failed_test_data = {}

function M.show_test_log()
	local buf = ui.create_window()
	-- api.nvim_buf_set_lines(buf, 0, -1, false, failed_test_data)
end

function M.execute_all(globs)
	local command = config.get("command")
	local bufnr = api.nvim_get_current_buf()
	local passed = false

	if command.clean then
		print("cleaning output of previous run..")
		vim.fn.jobstart("dotnet clean")
	end

	for k, test in pairs(globs.tests) do
		print("")
		local fqn = "FullyQualifiedName=" .. globs.namespace .. "." .. globs.classname .. "." .. test.name
		local cmd = { "dotnet", "test", "-v", "m", "--filter", fqn }

		local out = {}
		vim.fn.jobstart(cmd, {
			data_buffered = true,
			on_stdout = function(_, data)
				if not data then
					return
				end
				ui.set_virt(bufnr, globs.marks_ns, test, k, "Running..")
				for ln, line in ipairs(data) do
					table.insert(out, ln, { line })
				end
			end,
			on_exit = function()
				passed = analyze(out)
				if passed == true then
					ui.set_virt(bufnr, globs.marks_ns, test, k, " Passed!")
				elseif passed == false then
					ui.set_virt(bufnr, globs.marks_ns, test, k, " Failed!")
					table.insert(failed_test_data, k, { [test.name] = out })
					print(vim.inspect(failed_test_data))
				end
			end,
		})
	end
end

return M
