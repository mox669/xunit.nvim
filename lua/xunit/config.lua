local M = {}

local config = {
	command = {
		clean = true,
	},
}

function M.set(user_conf)
	user_conf = user_conf or {}
	config = vim.tbl_deep_extend("force", config, user_conf)
	return config
end

function M.get(key)
	if key then
		return config[key]
	end
	return config
end

return M
