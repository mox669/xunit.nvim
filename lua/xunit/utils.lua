local M = {}
local lazy = require("xunit.lazy")
local config = lazy.require("xunit.config")
local has_notify, notify = pcall(require, "notify")

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

return M
