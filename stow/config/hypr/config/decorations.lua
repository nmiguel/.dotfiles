local vars = require("config.vars")
local gaps_long = 20
local gaps_small = 4

hl.animation({
	leaf = "global",
	enabled = false,
})

hl.config({
	general = {
		layout = "scrolling",
		border_size = 3,
		gaps_in = 2,
		-- gaps_out = { top = 4, bottom = 4, left = 20, right = 20 },
        gaps_out = gaps_small,
		resize_on_border = true,
		allow_tearing = false,
		col = {
			active_border = "rgba(33ccffee)",
			-- active_border = {
			-- colors = { "rgba(33ccffee)", "rgba(0,0,0,0)", "rgba(33ccffee)", "rgba(0,0,0,0)", "rgba(33ccffee)" },
			-- angle = 35,
			-- },
			inactive_border = "rgba(121516de)",
		},
	},
})

hl.config({
	decoration = {
		rounding = 7,

		active_opacity = 0.98,
		inactive_opacity = 0.95,
		fullscreen_opacity = 1.0,

		-- dim_inactive = true,
		-- dim_strength = 0.05,

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

-- hl.workspace_rule({
-- 	workspace = string.format("m[%s]", vars.monitor2),
-- 	gaps_out = {
-- 		top = gaps_long,
-- 		bottom = gaps_long,
-- 		left = gaps_small,
-- 		right = gaps_small,
-- 	},
-- })

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = gaps_small })
