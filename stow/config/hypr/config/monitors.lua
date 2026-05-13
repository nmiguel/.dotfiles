local vars = require("config.vars")

hl.monitor({
	output = vars.monitor1,
	mode = "2560x1440@165",
	position = "1080x480",
	scale = "1",
})

hl.monitor({
	output = vars.monitor2,
	mode = "1920x1080",
	position = "0x0",
	scale = "1",
	transform = 3,
})
