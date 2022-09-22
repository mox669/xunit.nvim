local M = {}
-- local has_notify, notify = pcall(require, "notify")

-- M.has_notify = has_notify

function M.debug(prefix, data)
	local pre = prefix or ""
	print(pre .. vim.inspect(data))
end

-- function M.send_notification()
-- 	local title = "Xunit"
-- 	notify("This is an error message.\nSomething went wrong!", "error", {
-- 		title = title,
-- 		on_open = function()
-- 			notify("Attempting recovery.", vim.log.levels.WARN, {
-- 				title = title,
-- 			})
-- 			local timer = vim.loop.new_timer()
-- 			timer:start(2000, 0, function()
-- 				notify({ "Fixing problem.", "Please wait..." }, "info", {
-- 					title = title,
-- 					timeout = 3000,
-- 					on_close = function()
-- 						notify("Problem solved", nil, { title = title })
-- 						notify("Error code 0x0395AF", 1, { title = title })
-- 					end,
-- 				})
-- 			end)
-- 		end,
-- 	})
-- end

return M
