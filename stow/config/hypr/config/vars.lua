local M = {}

local monitors = require("config.monitors")

-- Resolve roles when used, since docking can change the selected outputs.
setmetatable(M, {
	__index = function(_, key)
		if key == "monitor_main" then
			return monitors.main
		elseif key == "monitor_aux" then
			return monitors.aux
		end
	end,
})

M.terminal = "ghostty"
M.mod = "SUPER"
M.mainMod = M.mod
M.scriptsDir = "$HOME/.config/bin"

M.terminal = "ghostty"
M.browser = "firefox"

return M
