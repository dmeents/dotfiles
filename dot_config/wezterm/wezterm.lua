-- WezTerm configuration
-- Nord palette for a consistent terminal look across machines. The Noctalia
-- shell owns desktop theming ("Noctalia (default)" scheme); this styles only
-- the terminal. JetBrainsMono Nerd Font (ttf-jetbrains-mono-nerd).
-- Multi-workflow is handled via WezTerm workspaces (LEADER + w) and Zellij on top.

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ── Nord palette ──────────────────────────────────────────────────────────
local nord = {
	polar0 = "#2E3440", polar1 = "#3B4252", polar2 = "#434C5E", polar3 = "#4C566A",
	snow4 = "#D8DEE9", snow5 = "#E5E9F0", snow6 = "#ECEFF4",
	frost7 = "#8FBCBB", frost8 = "#88C0D0", frost9 = "#81A1C1", frost10 = "#5E81AC",
	red = "#BF616A", orange = "#D08770", yellow = "#EBCB8B", green = "#A3BE8C", purple = "#B48EAD",
}

-- ── Appearance ──────────────────────────────────────────────────────────────
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Medium" },
	"Symbols Nerd Font Mono",
})
config.font_size = 11.0
config.line_height = 1.05
config.freetype_load_target = "Light"

config.color_scheme = "nordfox"
config.colors = {
	foreground = nord.snow4,
	background = nord.polar0,
	cursor_bg = nord.frost8,
	cursor_fg = nord.polar0,
	cursor_border = nord.frost8,
	selection_bg = nord.polar3,
	selection_fg = nord.snow6,
	ansi = { nord.polar1, nord.red, nord.green, nord.yellow, nord.frost9, nord.purple, nord.frost7, nord.snow4 },
	brights = { nord.polar3, nord.red, nord.green, nord.yellow, nord.frost8, nord.purple, nord.frost7, nord.snow6 },
	tab_bar = {
		background = nord.polar0,
		active_tab = { bg_color = nord.frost10, fg_color = nord.snow6, intensity = "Bold" },
		inactive_tab = { bg_color = nord.polar1, fg_color = nord.snow4 },
		inactive_tab_hover = { bg_color = nord.polar2, fg_color = nord.snow6 },
		new_tab = { bg_color = nord.polar0, fg_color = nord.polar3 },
		new_tab_hover = { bg_color = nord.polar2, fg_color = nord.snow6 },
	},
}

-- Window
config.window_background_opacity = 0.96
config.window_decorations = "NONE" -- Hyprland handles borders/rounding
config.window_padding = { left = 10, right = 10, top = 8, bottom = 6 }
-- This wezterm build's native Wayland backend fails to map a window on
-- Hyprland (the gui process starts but no surface appears). Run under XWayland,
-- which is reliable here. Revert to true if a newer wezterm fixes Wayland.
config.enable_wayland = false
config.adjust_window_size_when_changing_font_size = false

-- ── Tab bar ───────────────────────────────────────────────────────────────
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 28
config.show_new_tab_button_in_tab_bar = false

-- Show the active workspace on the right of the tab bar.
wezterm.on("update-right-status", function(window, _)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = nord.frost8 } },
		{ Text = "  " .. window:active_workspace() .. "  " },
	}))
end)

-- ── Keybindings ─────────────────────────────────────────────────────────────
-- LEADER = Ctrl+a (tmux-style). Frees Ctrl combos for the shell/apps.
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Splits
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Pane navigation
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	-- Tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	-- Workspaces (multi-workflow): fuzzy switcher + create
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "W",
		mods = "LEADER|SHIFT",
		action = act.PromptInputLine({
			description = wezterm.format({ { Text = "New workspace name:" } }),
			action = wezterm.action_callback(function(window, pane, line)
				if line and line ~= "" then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
	-- Font size / reload
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
}

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

return config
