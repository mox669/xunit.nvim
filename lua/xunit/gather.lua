-----
-- gather.lua: get all needed information for the testsuite
-----
local api = vim.api
local ui = require("xunit.ui")
local u = require("xunit.utils")

local M = {}
M.xunit_globs = {}

function M.trim(s)
	s = s:gsub(" ", "")
	return s
end

local function isolate_val(s)
	s = string.gsub(s, "%[InlineData%(", "")
	s = s:gsub("%)%]", "")
	return s
end

function M.gather()
	-- local api = vim.api
	local q = require("vim.treesitter.query")
	-- local namespace = vim.api.nvim_create_namespace("xunit")
	local bufnr = vim.api.nvim_get_current_buf()

	-- get the syntax_tree
	local language_tree = vim.treesitter.get_parser(bufnr, "c_sharp")
	local syntax_tree = language_tree:parse()
	local root = syntax_tree[1]:root()

	-- ts queries
	local q_namespace = vim.treesitter.parse_query(
		"c_sharp",
		[[
  (namespace_declaration
    name: (qualified_name) @namespace) 
]]
	)

	local q_classname = vim.treesitter.parse_query(
		"c_sharp",
		[[
  (class_declaration
    name: (identifier) @class)
]]
	)

	local q_test_case = vim.treesitter.parse_query(
		"c_sharp",
		[[
    (class_declaration
      (declaration_list
        (method_declaration 
          (attribute_list
            [(attribute
              name: (identifier) @fact (#eq? @fact "Fact"))
             (attribute
              name: (identifier) @theory (#eq? @theory "Theory"))
            ]) 
          name: (identifier) @test_case
          body: (block) @body (#offset! @body)) @method (#offset! @method)
      )
    )
    ]]
	)

	-- get namespace
	local ns
	for _, captures in q_namespace:iter_matches(root, bufnr) do
		ns = q.get_node_text(captures[1], bufnr)
	end
	local namespace = api.nvim_create_namespace(ns)

	-- get class
	local cls
	for _, captures, _ in q_classname:iter_matches(root, bufnr) do
		cls = q.get_node_text(captures[1], bufnr)
	end

	-- get tests
	local tests = {}

	--TODO (olekatpyle)  09/19/22 - 21:19: instead of using two queries to collect all
	-- neccessary data, figure out how to do it in one
	local i = 1
	for _, captures, metadata in q_test_case:iter_matches(root, bufnr) do
		-- collect all tests in file
		if captures[1] then
			table.insert(tests, {
				id = i,
				name = q.get_node_text(captures[3], bufnr),
				fact = true,
				inlines = {},
				line = metadata[5].range[1],
				offset = metadata[5].range,
			})
			-- debug("name: ", q.get_node_text(captures[1], bufnr))
		elseif captures[2] then
			local inlines = {}
			local val
			local k = 10
			for j = metadata[5].range[1] + 2, metadata[4].range[1] - 1 do
				val = api.nvim_buf_get_lines(bufnr, j - 1, j, true)[1]
				if val == "" or val.find(val, "//") ~= nil or val.find(val, "/%*") ~= nil then
				else
					val = M.trim(val)
					-- the inlines will be checked via string comparison, in order to find out which ones failed
					val = "(value: " .. isolate_val(val) .. ")"
					-- u.debug(val)

					table.insert(inlines, { i = k, l = j, v = val })
					k = k + 1
				end
			end
			table.insert(tests, {
				id = i,
				name = q.get_node_text(captures[3], bufnr),
				fact = false,
				inlines = inlines,
				line = metadata[5].range[1],
				offset = metadata[5].range,
			})
		end
		i = i + 1
	end

	-- u.debug(tests)

	local globs = {
		namespace = ns,
		classname = cls,
		tests = tests,
		marks_ns = namespace,
		--TODO (olekatpyle)  09/20/22 - 17:19: current gets resets to 0 on BufWrite -> that is bad since you have to reselect the test
	}

	M.xunit_globs[bufnr] = globs
	-- u.debug(M.xunit_globs)

	-- show virt text
	ui.set_ext_all(bufnr, namespace, M.xunit_globs[bufnr].tests, "Run test", "XVirtNormal")
end

return M
