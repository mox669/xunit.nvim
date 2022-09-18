local M = {}

function M.run_tests_virt(bufnr, ns, tests)
	print("UI: " .. vim.inspect(tests))
	for k, test in pairs(tests) do
		-- delete previous extmarks with given id
		vim.api.nvim_buf_del_extmark(bufnr, ns, k + 1)
		-- create extmark
		vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, {
			id = k + 1,
			--TODO (olekatpyle)  09/18/22 - 12:36: add custom HL-Group
			virt_text = { { " Run test", "" } },
			virt_text_pos = "eol",
			ui_watched = true,
		})
	end
end

return M
