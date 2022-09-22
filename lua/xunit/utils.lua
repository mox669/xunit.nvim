local M = {}
local has_notify, notify = pcall(require, "notify")

M.has_notify = has_notify

function M.debug(prefix, data)
	local pre = prefix or ""
	print(pre .. vim.inspect(data))
end

function M.send_notification(msg, status)
	local title = "Xunit"
	notify(msg, status, {
		title = title,
	})
end

return M
