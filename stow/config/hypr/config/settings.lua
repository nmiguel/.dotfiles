local vars = require("config.vars")

hl.config({ dwindle = {
	smart_split = false,
} })

hl.config({
	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})

hl.config({
	misc = {
		initial_workspace_tracking = 0,
        disable_splash_rendering = true,
        disable_hyprland_logo = true,
	},
})

hl.config({ scrolling = {
	explicit_column_widths = "0.5,0.985",
	follow_min_visible = 1.0,
    -- focus_fit_method = 0,
} })

-- hl.on("workspace.move_to_monitor", function(ws, m)
-- 	hl.notification.create({ text = m.name, duration = 2000 })
-- 	local layout = "scrolling"
-- 	if m.name == vars.monitor2 then
-- 		hl.notification.create({ text = "Here", duration = 2000 })
-- 		layout = "dwindle"
-- 	end
-- 	hl.workspace_rule({ workspace = ws.id, layout = layout })
-- end)
--
hl.workspace_rule({ workspace = string.format("m[%s]", vars.monitor2), layout_opts = { direction = "up" } })

-- cursor {
--     no_warps = true,
--     warp_on_change_workspace = 0,
-- }
