local M = {}
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
local parser = require("xunit.parser")
local has_notify, notify = pcall(require, "notify")
local api = vim.api

function M.send_notification(msg, status)
  if has_notify and config.notify then
    local title = "Xunit"
    notify(msg, status, {
      title = title,
    })
  else
    return
  end
end

-- debugging

function M.debug(prefix, data)
  local pre = prefix or ""
  print(pre .. vim.inspect(data))
end

function M.inspect_data()
  local buf = api.nvim_get_current_buf()
  print("Current namespace -> " .. parser.xunit_globs[buf].namespace)
  print("Classname         -> " .. parser.xunit_globs[buf].classname)
  print("\n")
  print("+-------------------------TESTS-------------------------+\n")
  for _, test in pairs(parser.xunit_globs[buf].tests) do
    print("TEST: " .. test.name .. " at line " .. test.line)
    print("Range -> ", vim.inspect(test.offset))
    print("\n")
  end
end

return M
