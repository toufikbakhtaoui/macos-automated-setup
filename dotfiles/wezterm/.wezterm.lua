-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Settings
--config.color_scheme = "Tokyo Night"
config.color_scheme = "Catppuccin Macchiato"

-- This is where you actually apply your config choices

config.font = wezterm.font_with_fallback({
	{ family = "CaskaydiaCove Nerd Font", scale = 1.1 },
})

config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "home"

-- Dim inactive panes
config.inactive_pane_hsb = {
	saturation = 0.24,
	brightness = 0.5,
}

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

config.use_fancy_tab_bar = false
config.status_update_interval = 1000

config.default_cwd = "/Volumes/Media/dev/applications/java-apps"

-- and finally, return the configuration to wezterm
return config
