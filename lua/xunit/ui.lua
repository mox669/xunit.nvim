local M = {}

function M.set_virt_all(bufnr, ns, tests, virt_text)
	for k, test in pairs(tests) do
		M.set_virt(bufnr, ns, test, k, virt_text)
	end
end

function M.set_virt(bufnr, ns, test, k, virt_text)
	-- delete previous extmarks with given id
	vim.api.nvim_buf_del_extmark(bufnr, ns, k)
	-- create extmark
	vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, {
		id = k,
		--TODO (olekatpyle)  09/18/22 - 12:36: add custom HL-Group
		virt_text = { { virt_text, "" } },
		virt_text_pos = "eol",
		ui_watched = true,
	})
end

return M
