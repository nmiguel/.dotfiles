local vars = require("config.vars")

local function apply_tag(tag, rules)
	for _, rule in ipairs(rules) do
		hl.window_rule({
			match = rule,
			tag = "+" .. tag,
		})
	end
end

local function tagged_rule(name, opts)
	opts.name = name
	opts.match = { tag = name .. "*" }

	hl.window_rule(opts)
end

-- Browser
apply_tag("browser", {
	{ class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr|[Ff]irefox-bin)$" },
	{ class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$" },
	{ class = "^(chrome-.+-Default)$" },
	{ class = "^([Mm]icrosoft-edge(-stable|-beta|-dev|-unstable))$" },
	{ class = "^(Brave-browser(-beta|-dev|-unstable)?)$" },
	{ class = "^([Tt]horium-browser|[Cc]achy-browser)$" },
	{ class = "^(zen-alpha|zen)$" },
})

-- Notifications
apply_tag("notif", {
	{ class = "^(swaync-control-center|swaync-notification-window|swaync-client|class)$" },
})

-- Music
apply_tag("music", {
	{ class = "^(Spotify)$" },
	{ class = "^(com.github.th_ch.youtube_music)$" },
})

tagged_rule("music", {
	workspace = "3 silent",
	opacity = "0.95 0.85",
})

-- Terminals
apply_tag("terminal", {
	{
		class = "^(com.mitchellh.ghostty|Alacritty|kitty|kitty-dropterm|org.wezfurlong.wezterm|tmux)$",
	},
})

-- Email
apply_tag("email", {
	{ class = "^([Tt]hunderbird|org.gnome.Evolution)$" },
	{ class = "^(eu.betterbird.Betterbird)$" },
})

-- Projects
apply_tag("projects", {
	{ class = "^(codium|codium-url-handler|VSCodium)$" },
	{ class = "^(VSCode|code-url-handler)$" },
	{ class = "^(jetbrains-.+)$" },
})

-- Screenshare
apply_tag("screenshare", {
	{ class = "^(com.obsproject.Studio)$" },
})

-- Instant Messaging
apply_tag("im", {
	{ class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$" },
	{ class = "^([Ff]erdium)$" },
	{ title = "^(web\\.whatsapp\\.com.*)$" },
	{ class = "^([Ww]hatsapp-for-linux)$" },
	{ class = "^(ZapZap|com.rtosta.zapzap)$" },
	{ class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$" },
	{ class = "^(teams-for-linux)$" },
})

tagged_rule("im", {
	workspace = "3 silent",
	opacity = "0.95 0.93",
})

-- AI
apply_tag("ai", {
	{ initial_title = "(.*[Cc]hat[Gg][Pp][Tt].*)" },
})

tagged_rule("ai", {
	workspace = "6 silent",
})

-- Games
apply_tag("games", {
	{ class = "^(gamescope)$" },
	{ class = "^(steam_app_\\d+)$" },
})

tagged_rule("games", {
	workspace = "5",
	no_blur = true,
	fullscreen = true,
	fullscreen_state = "3 3",
	opacity = "1.0 override 1.0 override",
})

-- Game Stores
apply_tag("gamestore", {
	{ class = "^([Ss]team)$" },
	{ title = "^([Ll]utris)$" },
	{ class = "^(com.heroicgameslauncher.hgl)$" },
})

tagged_rule("gamestore", {
	workspace = "5 silent",
})

-- File Managers
apply_tag("file-manager", {
	{ class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$" },
	{ class = "^(app.drey.Warp)$" },
})

tagged_rule("file-manager", {
	opacity = "0.85 0.85",
})

-- Wallpaper
apply_tag("wallpaper", {
	{ class = "^([Ww]aytrogen)$" },
})

tagged_rule("wallpaper", {
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.7" },
})

-- Multimedia
apply_tag("multimedia", {
	{ class = "^([Aa]udacious)$" },
})

apply_tag("multimedia_video", {
	{ class = "^([Mm]pv|vlc)$" },
})

tagged_rule("multimedia_video", {
	no_blur = true,
	opacity = "1.0 override 1.0 override",
})

-- Settings
apply_tag("settings", {
	{ title = "^(ROG Control)$" },
	{ class = "^(wihotspot(-gui)?)$" },
	{ class = "^([Bb]aobab|org.gnome.[Bb]aobab)$" },
	{ class = "^(gnome-disks)$" },
	{ title = "(Kvantum Manager)" },
	{ class = "^(file-roller|org.gnome.FileRoller)$" },
	{ class = "^(nm-applet|nm-connection-editor|blueman-manager)$" },
	{ class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" },
	{ class = "^(qt5ct|qt6ct|[Yy]ad)$" },
	{ class = "(xdg-desktop-portal-gtk)" },
	{ class = "^(org.kde.polkit-kde-authentication-agent-1)$" },
	{ class = "^([Rr]ofi)$" },
})

tagged_rule("settings", {
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.7" },
})

-- Viewers
apply_tag("viewer", {
	{
		class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$",
	},
	{ class = "^(evince)$" },
	{ class = "^(eog|org.gnome.Loupe)$" },
})

tagged_rule("viewer", {
	float = true,
})

-- Floating Windows
apply_tag("floating-window", {
	{
		class = "(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float)",
	},
	{
		class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors)",
		title = "^(Open.*Files?|Save.*Files?|Save.*As|All Files|Save)",
	},
})

tagged_rule("floating-window", {
	float = true,
	center = true,
	opacity = "1 override 1 override",
	size = { "monitor_w*0.8", "monitor_h*0.8" },
})

-- Fullscreen idle inhibit
hl.window_rule({
	name = "idle-inhibit-fullscreen",
	match = { fullscreen = true },
	idle_inhibit = "fullscreen",
})

-- Picture in Picture
hl.window_rule({
	name = "picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },
	opacity = "1.0 override 1.0 override",
	pin = true,
})
