-----
-- gather.lua: get all needed information for the testsuite
-----

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

	-- get class
	local cls
	for _, captures in q_classname:iter_matches(root, bufnr) do
		cls = q.get_node_text(captures[1], bufnr)
	end

	M.tests = {}
	local i = 1
	-- get tests
	for _, captures, metadata in q_test_case:iter_matches(root, bufnr) do
		local test_case = q.get_node_text(captures[2], bufnr)
		-- collect all tests in file
		table.insert(M.tests, i, {
			name = test_case,
			line = metadata[1].range[1],
			meta = metadata,
		}) -- table.insert(tests, i, { test, metadata[1].range[1], metadata })
		i = i + 1
	end

	for key, test in pairs(M.tests) do
		debug(key)
		debug(test)
		debug("name: " .. test.name)
		debug("line: " .. test.line)
		debug(test.meta)
	end

	debug(ns)
	debug(cls)
	-- local test_path = ns .. "." .. cls .. "." .. tests[1][1]
	-- debug(test_path)
	M.data = {
		namespace = { ns },
		classname = { cls },
	}

	print(M.data.namespace)
	print(M.data.classname)
end

return M
