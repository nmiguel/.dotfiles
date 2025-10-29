-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- config.enable_wayland = false

config.default_prog = { "tmux" }
-- config.default_domain = "WSL:Ubuntu-22.04"
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

local background = require("background")
config.background = "#131A21"

config.color_scheme = "BlueDolphin"
config.colors = require("./theme")

local tabbar = require("tabBar")
tabbar.apply_to_config(config)
config.show_new_tab_button_in_tab_bar = false
local keys = require("keybinds")
keys.apply_to_config(config)

config.max_fps = 165
-- config.front_end = "WebGpu"

config.cursor_thickness = 2

config.window_decorations = "NONE"
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

return config
