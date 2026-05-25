local vars = require("config.vars")

local function startup_workspace_rule(opts)
	local rule = hl.window_rule({
		name = opts.name,
		match = opts.match,
		workspace = opts.workspace .. " silent",
        monitor = opts.monitor .. " silent",
	})

	hl.exec_cmd(opts.command)

	hl.timer(function(timerOpts)
		timerOpts.rule:set_enabled(false)
	end, {
		timeout = opts.timeout or 30000,
		type = "oneshot",
		rule = rule,
	})
end

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP=Hyprland")
	hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP")

	hl.exec_cmd("dms run")

	-- Utilities
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("mako")
	hl.exec_cmd("ags")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("thunar --daemon")
	hl.exec_cmd("elephant")
	hl.exec_cmd("openrgb -p Default")
	hl.exec_cmd("fcitx5")

	-- Normal apps
	hl.exec_cmd(vars.terminal, { workspace = "1", monitor = vars.monitor1 })
	hl.exec_cmd(vars.browser, { workspace = "2", monitor = vars.monitor2 })

	-- Startup-routed apps
	startup_workspace_rule({
		name = "startup-steam",
		match = { class = "^(steam)$" },
		workspace = "5",
		monitor = vars.monitor1,
		command = "steam",
	})

	startup_workspace_rule({
		name = "startup-youtube-music",
		match = { class = "^(youtube-music)$" },
		workspace = "3",
		monitor = vars.monitor2,
		command = "youtube-music",
	})

	startup_workspace_rule({
		name = "startup-whatsapp",
		match = { title = "^(WhatsApp)$" },
		workspace = "3",
		monitor = vars.monitor2,
		command = "chromium --app=https://web.whatsapp.com",
	})

	startup_workspace_rule({
		name = "startup-chatgpt",
		match = { title = "^(ChatGPT)$" },
		workspace = "6",
		monitor = vars.monitor2,
		command = "chromium --app=https://chatgpt.com",
	})
end)
