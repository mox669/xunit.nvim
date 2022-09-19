local M = {}

local api = vim.api
local Job = require("plenary.job")
local config = require("xunit.config")
local ui = require("xunit.ui")
local u = require("xunit.utils")
local test_data = {}

local function analyze()
	--TODO (olekatpyle)  09/18/22 - 17:32: find a smoother way to check if success?
	for _, line in ipairs(test_data) do
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
				ui.set_ext(bufnr, globs.marks_ns, test.line, k, " Failed!", "XVirtFailed")
				break
			else
				ui.set_ext(bufnr, globs.marks_ns, test.line, k, " Passed!", "XVirtPassed")
			end
		end
	end
end

function M.show_test_result()
	local buf = ui.create_window()
	api.nvim_buf_set_option(buf, "modifiable", true)
	api.nvim_buf_set_lines(buf, 0, -1, false, {
		ui.center_text("TEST RESULT"),
	})
	api.nvim_buf_set_lines(buf, 1, -1, false, {
		ui.center_text("+---------------+"),
	})
	api.nvim_buf_set_lines(buf, 3, -1, false, test_data)
	api.nvim_buf_set_option(buf, "modifiable", false)
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

function M.execute_test()
	local bufnr = api.nvim_get_current_buf()
	local win = api.nvim_get_current_win()
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local current = globs.current
	local test = globs.tests[current]
	local cwd = vim.fn.expand("%:h")
	local clean = config.get("command").clean
	-- get current cursor row
	local r = api.nvim_win_get_cursor(win)[1]

	-- get range of test in syntax tree
	local x1 = test.line
	local x2 = test.offset[3]

	if r >= x1 and r <= x2 then
		if clean then
			Job
				:new({
					command = "dotnet",
					args = { "clean" },
					cwd = cwd,
				})
				:sync()
		end
		local fqn = "FullyQualifiedName=" .. globs.namespace .. "." .. globs.classname .. "." .. test.name
		local cmd = "dotnet test -v m --filter " .. fqn
		ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, "Running ..", "XVirtNormal")
		test_data = {}
		vim.fn.jobstart(cmd, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				if not data then
					return
				end
				for i, line in ipairs(data) do
					table.insert(test_data, i, line)
				end
			end,
			on_exit = function()
				local passed = analyze()
				if passed then
					ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, " Passed!", "XVirtPassed")
				else
					ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, " Failed!", "XVirtFailed")
				end
			end,
		})
	else
		print("Currently no test selected ..")
	end
end

return M
