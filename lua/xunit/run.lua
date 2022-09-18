local M = {}

local config = require("xunit.config")
local ui = require("xunit.ui")

local function analyze_output(data)
	print(vim.inspect(data))
	--TODO (olekatpyle)  09/18/22 - 17:32: find a smoother way to check if success?
	for _, line in ipairs(data) do
		if line[1].find(line[1], "Fehler!") or line[1].find(line[1], "Failed!") then
			return false
		end
	end
	return true
end

function M.execute_all(globs)
	local command = config.get("command")
	local bufnr = vim.api.nvim_get_current_buf()
	local passed = false

	if command.clean then
		print("cleaning..")
		vim.fn.jobstart("dotnet clean")
	end

	for k, test in pairs(globs.tests) do
		local fqn = "FullyQualifiedName=" .. globs.namespace .. "." .. globs.classname .. "." .. test.name

		local cmd = { "dotnet", "test", "-v", "d", "--filter", fqn }
		local out = {}
		vim.fn.jobstart(cmd, {
			data_buffered = true,
			on_stdout = function(_, data)
				if not data then
					return
				end
				ui.set_virt(bufnr, globs.marks_ns, test, k, "Running...")
				for ln, line in ipairs(data) do
					table.insert(out, ln, { line })
				end
			end,
			on_exit = function()
				passed = analyze_output(out)
				print(passed)
				if passed == true then
					ui.set_virt(bufnr, globs.marks_ns, test, k, " Passed!")
				elseif passed == false then
					ui.set_virt(bufnr, globs.marks_ns, test, k, " Failed!")
				end
			end,
		})
	end
end

return M
