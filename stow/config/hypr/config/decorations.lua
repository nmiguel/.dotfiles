hl.animation({
	leaf = "global",
	enabled = false,
})

hl.config({
	general = {
        layout = "scrolling",
		border_size = 2,
		gaps_in = 2,
		gaps_out = { top = 4, bottom = 4, left = 20, right = 20},
		resize_on_border = true,
		allow_tearing = false,
		col = {
			active_border = {
				colors = { "rgba(33ccffee)", "rgba(0,0,0,0)", "rgba(33ccffee)", "rgba(0,0,0,0)", "rgba(33ccffee)" },
				angle = 35,
			},
			inactive_border = "rgba(0,0,0,0)",
		},
	},
})

hl.config({
	decoration = {
		rounding = 7,

		active_opacity = 0.98,
		inactive_opacity = 0.95,
		fullscreen_opacity = 1.0,

		dim_inactive = true,
		dim_strength = 0.1,

		shadow = {
			-- enabled = false,
		},

		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			ignore_opacity = false,
			new_optimizations = true,
			xray = true,
			special = true,
			popups = true,
		},
	},
})
