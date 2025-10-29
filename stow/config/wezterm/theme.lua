local colors = {}

local pallette = {
	black = "#040404", -- #282828 or #0c0e0f
	grey = "#282828",
	dark_blue = "#011826",
	red = "#EE5396",
	green = "#25be6a", -- #25be6a or #42BE65
	yellow = "#08BDBA",
	blue = "#005e7d",
	magenta = "#BE95FF",
	cyan = "#33B1FF",
	white = "#dfdfe0",
	orange = "#3DDBD9",
	pink = "#FF7EB6",
    clear = "rgba(0, 0, 0, 0)",
}

colors.foreground = pallette.white
colors.cursor_bg = pallette.white
colors.cursor_fg = pallette.yellow
colors.split = pallette.white
colors.copy_mode_active_highlight_bg = { Color = pallette.orange}

colors.tab_bar = {
  background = 'none',
  active_tab  = {
    bg_color = pallette.blue,
    fg_color = pallette.white
  },
  inactive_tab = {
    bg_color = pallette.black,
    fg_color = pallette.white
  },
  new_tab = {
    bg_color = pallette.black,
    fg_color = pallette.white
  }
}

return colors
