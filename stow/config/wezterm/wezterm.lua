-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- config.enable_wayland = false

config.wsl_domains = {
	{
		name = "WSL:Ubuntu-22.04",
		distribution = "Ubuntu-22.04",
		default_cwd = "~",
		default_prog = { "fish" },
	},
}

config.default_prog = { "tmux" }
config.default_domain = "WSL:Ubuntu-22.04"
-- config.debug_key_events = true
config.warn_about_missing_glyphs = false
-- This will hold the configuration.

-- Configure font and font size
config.font = wezterm.font_with_fallback({
	{ family = "CommitMono" },
	{ family = "Symbols Nerd Font Mono" },
	{ family = "Noto Color Emoji" },
	{ family = "CaskaydiaMono Nerd Font" },
	-- { family = "Cascadia Mono" },
})
config.font_size = 16
config.underline_thickness = 4

config.background = {
	{
		source = {
			Color = "#131a21",
		},
		width = "110%",
		horizontal_offset = "-5%",
		height = "110%",
		vertical_offset = "-5%",
		opacity = 1,
	},
}

config.color_scheme = "BlueDolphin"
config.colors = require("./theme")

config.show_new_tab_button_in_tab_bar = false

config.max_fps = 165
-- config.front_end = "WebGpu"

config.cursor_thickness = 2

config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_padding = {
	left = 10,
	right = 10,
	top = 5,
	bottom = 0,
}

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
