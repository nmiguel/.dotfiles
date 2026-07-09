local M = {}

M.main = "DP-2"
M.aux = "DP-3"

hl.monitor({
	output = M.main,
	mode = "2560x1440@165",
	position = "1080x480",
	scale = "1",
})

hl.monitor({
	output = M.aux,
	mode = "1920x1080",
	position = "0x0",
	scale = "1",
	transform = 3,
})

return M
