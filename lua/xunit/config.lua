local M = {}

local config = {
	command = {
		-- perform 'dotnet clean' default true
		clean = true,
	},
	--TODO (olekatpyle)  09/18/22 - 21:37: ui configs
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
