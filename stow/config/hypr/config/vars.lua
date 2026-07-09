local M = {}

local monitors = require("config.monitors")

M.monitor_main = monitors.main
M.monitor_aux = monitors.aux
-- hl.notification.create({ text = monitor_main, duration = 1000})

-- M.monitor_main = "DP-3"
-- M.monitor_aux = "DP-2"

M.terminal = "ghostty"
M.mod = "SUPER"
M.mainMod = M.mod
M.scriptsDir = "$HOME/.config/bin"

M.terminal = "ghostty"
M.browser = "firefox"

return M
