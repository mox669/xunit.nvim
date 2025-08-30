----
-- xunit.controls
-- Handles cursor movement to jump between tests
----
local M = {}
local api = vim.api

function M.jumpto_next()
  local bufnr = api.nvim_get_current_buf()
  local globs = require("xunit.parser").xunit_globs[bufnr]
  local uglobs = require("xunit.ui").ui_globs[bufnr]
  local current = uglobs.current

  if current == #globs.tests or current == 0 then
    uglobs.current = 1
  else
    uglobs.current = current % #globs.tests + 1
  end

  local test = globs.tests[uglobs.current]
  local line = test.line
  local row
  if test.fact then
    row = line + 2
  else
    row = line + 2 + #test.inlines
  end
  local col = test.offset[2]

  vim.api.nvim_win_set_cursor(0, { row, col })
end

function M.jumpto_prev()
  local bufnr = api.nvim_get_current_buf()
  local globs = require("xunit.parser").xunit_globs[bufnr]
  local uglobs = require("xunit.ui").ui_globs[bufnr]
  local current = uglobs.current

  if current <= 1 then
    uglobs.current = #globs.tests
  else
    uglobs.current = (current - 1) % #globs.tests
  end

  local test = globs.tests[uglobs.current]
  local line = test.line
  local row
  if test.fact then
    row = line + 2
  else
    row = line + 2 + #test.inlines
  end
  local col = test.offset[2]

  vim.api.nvim_win_set_cursor(0, { row, col })
end

return M
