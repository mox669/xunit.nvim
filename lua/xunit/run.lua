local M = {}

local api = vim.api
local Job = require("plenary.job")
local config = require("xunit.config")
local ui = require("xunit.ui")
local u = require("xunit.utils")
local test_data = {}

local function analyze(data)
	--TODO (olekatpyle)  09/18/22 - 17:32: find a smoother way to check if success?
	for _, line in ipairs(data) do
		if line.find(line, "Fehler!") or line.find(line, "Failed!") then
			return false
		end
	end
	return true
end

local function analyze_all(bufnr, globs)
	local foutput = {}
	for i, line in ipairs(test_data) do
		if line.find(line, "Failed") then
			table.insert(foutput, i, { line })
		end
	end
	-- u.debug(output)

	for k, test in pairs(globs.tests) do
		for _, ftest in pairs(foutput) do
			local fqn = globs.namespace .. "." .. globs.classname .. "." .. test.name
			-- u.debug(ftest)
			if ftest[1].find(ftest[1], fqn) ~= nil then
				ui.set_ext(bufnr, globs.marks_ns, test, k, " Failed!")
				break
			else
				ui.set_ext(bufnr, globs.marks_ns, test, k, " Passed!")
			end
		end
	end
end

function M.show_test_log()
	local buf = ui.create_window()
	api.nvim_buf_set_lines(buf, 0, -1, false, test_data)
end

function M.execute_all()
	local bufnr = api.nvim_get_current_buf()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local clean = config.get("command").clean
	-- local user_test_args = config.get("command").test_args
	local cwd = vim.fn.expand("%:h")
	-- ui.set_virt_all(bufnr, globs.marks_ns, globs.tests, "Running ..")

	if clean then
		Job
			:new({
				command = "dotnet",
				args = { "clean" },
				cwd = cwd,
			})
			:sync()
	end

	Job
		:new({
			command = "dotnet",
			args = { "test" },
			cwd = cwd,
			detached = true,
			on_exit = function(j)
				-- u.debug(j:result())
				test_data = j:result()
			end,
		})
		:sync()

	-- u.debug(test_data)
	analyze_all(bufnr, globs)
	print("Finished tests!")
end

return M
