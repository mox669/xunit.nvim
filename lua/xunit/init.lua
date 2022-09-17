local gather = require("xunit.gather")
local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("xunit-test", { clear = true }),
	pattern = "*.cs",
	callback = gather.gather(bufnr),
})
local M = {}

return M
