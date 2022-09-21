----
-- xunit.run
-- Handles test execution and logs test output data
----
local M = {}

local api = vim.api
local Job = require("plenary.job")
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
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

local function analyze_theory(test, bufnr)
	local f = {}
	local virt = config.virt_text
	local globs = require("xunit.gather").xunit_globs[bufnr]
	local passed = true
	for _, line in ipairs(test_data) do
		if line.find(line, "Failed") then
			table.insert(f, line)
		end
	end

	if f then
		table.remove(f, #f)
		-- u.debug(f)
		local failed = false
		-- u.debug(test.inlines)
		for _, inline in pairs(test.inlines) do
			print("next inline")
			-- u.debug(inline)
			for _, line in ipairs(f) do
				-- u.debug(line)
				local v = line:match("%b()")
				if inline.v == v then
					ui.set_ext(bufnr, globs.marks_ns, inline.l - 1, inline.i, virt.inln_failed, "XVirtFailed")
					-- passed will be returned to execute_test
					passed = false
					-- local flag
					failed = true
				end
			end
			if not failed then
				ui.set_ext(bufnr, globs.marks_ns, inline.l - 1, inline.i, virt.inln_passed, "XVirtPassed")
			end
			failed = false
		end
	end

	return passed
end

local function analyze_all(bufnr, globs)
	local foutput = {}
	local virt = config.virt_text
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
				-- ui.set_ext(bufnr, globs.marks_ns, test.line, k, " Failed!", "XVirtFailed")
				ui.set_ext(bufnr, globs.marks_ns, test.line, k, virt.failed, "XVirtFailed")
				break
			else
				-- ui.set_ext(bufnr, globs.marks_ns, test.line, k, " Passed!", "XVirtPassed")
				ui.set_ext(bufnr, globs.marks_ns, test.line, k, virt.passed, "XVirtPassed")
			end
		end
	end
end

local function noquiet(verbosity)
	if verbosity == "q" then
		print("Misconfiguration. Verbosity [q]uiet is not allowed! Check your config. Aborting test run ...")
		return true
	end
	return false
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
	local commands = config.commands
	local clean = commands.clean

	local cargs = { "clean" }
	local c = commands.cargs

	local verb = commands.verbosity
	if noquiet(verb) then
		return
	end

	local targs = { "test", "-v", verb }
	local t = commands.targs

	-- add user conf to argument list
	for _, arg in ipairs(c) do
		table.insert(cargs, arg)
	end
	for _, arg in ipairs(t) do
		table.insert(targs, arg)
	end

	-- set the cwd to the path of the file, that is currently loaded inside the buffer
	local cwd = vim.fn.expand("%:h")

	if clean then
		Job
			:new({
				command = "dotnet",
				args = cargs,
				cwd = cwd,
			})
			:sync()
	end

	Job
		:new({
			command = "dotnet",
			args = targs,
			cwd = cwd,
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
	local current = require("xunit.ui").ui_globs[bufnr].current
	local test = globs.tests[current]
	local commands = config.commands
	local cwd = vim.fn.expand("%:h")
	local clean = commands.clean
	local cargs = { "clean" }
	local virt = config.virt_text
	local c = commands.cargs
	for _, arg in ipairs(c) do
		table.insert(cargs, arg)
	end
	local verb = commands.verbosity
	if noquiet(verb) then
		return
	end
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
					args = cargs,
					cwd = cwd,
				})
				:sync()
		end
		local targs = { "dotnet", "test", "-v", verb }
		local t = commands.targs
		for _, arg in ipairs(t) do
			table.insert(targs, arg)
		end
		local fqn = "FullyQualifiedName=" .. globs.namespace .. "." .. globs.classname .. "." .. test.name
		table.insert(targs, "--filter")
		table.insert(targs, fqn)
		-- local cmd = "dotnet test -v m --filter " .. fqn

		ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, virt.running, "XVirtNormal")
		test_data = {}

		vim.fn.jobstart(targs, {
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
				local passed
				if test.fact then
					passed = analyze()
				else
					passed = analyze_theory(test, bufnr)
				end
				if passed then
					ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, virt.passed, "XVirtPassed")
				else
					ui.set_ext(bufnr, globs.marks_ns, test.line, test.id, virt.failed, "XVirtFailed")
				end
			end,
		})
	else
		print("Currently no test selected ..")
	end
end

return M
