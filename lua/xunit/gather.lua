-----
-- gather.lua: get all needed information for the testsuite
-----
local api = vim.api
local ui = require("xunit.ui")

local M = {}

function M.gather(bufnr)
	-- local api = vim.api
	local q = require("vim.treesitter.query")
	-- local namespace = vim.api.nvim_create_namespace("xunit")

	local function debug(value)
		print(vim.inspect(value))
	end

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
    (method_declaration
      (attribute_list
        (attribute
          name: (identifier) @fact (#eq? @fact "Fact") (#offset! @fact)))
    name: (identifier) @test_case)
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
	for _, captures in q_classname:iter_matches(root, bufnr) do
		cls = q.get_node_text(captures[1], bufnr)
	end

	-- get tests
	local tests = {}

	for _, captures, metadata in q_test_case:iter_matches(root, bufnr) do
		local test_case = q.get_node_text(captures[2], bufnr)
		-- collect all tests in file
		table.insert(tests, {
			name = test_case,
			line = metadata[1].range[1],
			meta = metadata,
		})
	end

	-- for _, test in pairs(tests) do
	-- 	debug(test.name)
	-- 	debug(test.line)
	-- 	debug(test.meta)
	-- end

	M.xunit_globs = {
		namespace = ns,
		classname = cls,
		tests = tests,
		marks_ns = namespace,
	}

	-- show virt text
	ui.set_virt_all(bufnr, namespace, M.xunit_globs.tests, " Run tests")
end

return M
