local M = {}

local config = {
	command = {
		-- perform 'dotnet clean' default true
		clean = true,
		-- change the verobsity level of the test log: [m]inimal | [n]ormal | [d]etailed | [diag]nostic
		-- defaults to minimal. (See dotnet test --help)
		-- NOTE: more detailed logs may have impact on performance
		verbosity = "m",
		-- add additional arguements to dotnet [t]est (see dotnet test --help for all options)
		targs = {},
		-- add additional arguments to dotnet [c]lean (see dotnet clean --help for all options)
		cargs = {},
	},
	-- change the virt_text annotation text displayed in the file
	virt_text = {
		idle = "Run test",
		running = "Running...",
		passed = "Passed!",
		failed = "Failed!",
		inln_passed = "ok",
		inln_failed = "x",
	},
	border = { "┌", "─", "┐", "└", "┘", "│" },
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

return setmetatable(M, {
	__index = function(_, k)
		return config[k]
	end,
})
