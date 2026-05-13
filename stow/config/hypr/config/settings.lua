local vars = require("config.vars")

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
-- windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

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
	},
})

hl.config({ scrolling = {
	explicit_column_widths = "0.5,1.0",
} })

hl.workspace_rule({ workspace = string.format("m[%s]", vars.monitor2), layout = "dwindle" })

hl.on("window.open", function(window)
    if window.title == "Picture-in-Picture" then
        hl.dispatch(hl.dsp.window.resize({window = window, y = 580, x = 1050}))
        end
end)

-- cursor {
--     no_warps = true,
--     warp_on_change_workspace = 0,
-- }
