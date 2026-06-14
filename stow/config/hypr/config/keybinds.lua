local vars = require("config.vars")
local mod = vars.mod
local scriptsDir = vars.scriptsDir

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + BackSpace", hl.dsp.window.close())
hl.bind(mod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mod .. " + V", hl.dsp.window.float())
hl.bind(
	mod .. " + SHIFT + V",
	hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy && wtype -M ctrl -k v -m ctrl")
)
hl.bind(mod .. " + B", hl.dsp.exec_cmd(vars.browser))

-- hl.bind(mod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
-- hl.bind(mod .. " + Comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
-- hl.bind(mod .. " + R", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + Comma", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind(mod .. " + R", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))

hl.bind(mod .. " + F", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("colresize -conf"))
	else
		hl.dsp.window.fullscreen({ mode = "maximized" })
	end
end)

hl.bind(mod .. " + semicolon", function()
	local curr_ws = hl.get_active_workspace()
	if curr_ws == nil then
		return
	end
	local windows = hl.get_workspace_windows(curr_ws)

	if windows == nil or curr_ws.tiled_layout ~= "scrolling" then
		return
	end
	local count = 0
	for _ in pairs(windows) do
		count = count + 1
	end
	local size = 1.0 / count

	hl.dispatch(hl.dsp.layout("colresize all " .. size .. ""))
end)

hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind(mod .. " + M", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mod .. " + S", hl.dsp.workspace.swap_monitors({ monitor1 = vars.monitor1, monitor2 = vars.monitor2 }))
hl.bind(
	mod .. " + SHIFT + S",
	hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | satty -f - -o "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png"')
)
hl.bind(
	mod .. " + T",
	hl.dsp.exec_cmd(
		'pkill rofi || true && rofi -modi "vol:'
			.. scriptsDir
			.. '/volume_mixer.py" -show vol -kb-custom-1 "Alt+Left" -kb-custom-2 "Alt+Right"'
	)
)

hl.bind(mod .. " + A", hl.dsp.exec_cmd(scriptsDir .. "/audio_switch.sh"))

-- Move focus
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + BracketLeft", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("consume_or_expel prev"))
	end
end)
hl.bind(mod .. " + BracketRight", function()
	if hl.get_active_workspace().tiled_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("consume_or_expel next"))
	end
end)

-- Switch workspaces with mod + [0-9]
-- Move active window to a workspace with mod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse move/resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
