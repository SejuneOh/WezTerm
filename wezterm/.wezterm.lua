local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Plugins
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")

-- Font
config.font = wezterm.font("D2CodingLigature Nerd Font")
config.font_size = 10.0

-- Color Theme
config.color_scheme = "Tokyo Night"

-- Background Opacity
config.window_background_opacity = 0.92

-- Default to WSL
config.default_domain = "WSL:Ubuntu"

-- Tab Bar
config.use_fancy_tab_bar = false

-- Window Padding
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Tabline
tabline.setup({
  options = {
    theme = "Tokyo Night",
  },
})

-- Smart Workspace Switcher
workspace_switcher.apply_to_config(config)

-- Keybindings
config.keys = {
  -- Workspace switcher (Alt+s)
  {
    key = "s",
    mods = "ALT",
    action = workspace_switcher.switch_workspace(),
  },
  -- Previous workspace (Alt+n)
  {
    key = "n",
    mods = "ALT",
    action = workspace_switcher.switch_to_prev_workspace(),
  },
  -- Copy (Ctrl+c)
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action.CopyTo("Clipboard"),
  },
  -- Paste (Ctrl+v)
  {
    key = "v",
    mods = "CTRL",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
  -- Split pane horizontally — 좌/우 (Ctrl+Shift+d)
  {
    key = "d",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- Split pane vertically — 상/하 (Ctrl+Shift+D)
  {
    key = "D",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- Close current pane (Ctrl+Shift+w)
  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentPane({ confirm = true }),
  },
  -- Toggle pane zoom (Ctrl+Shift+z)
  {
    key = "z",
    mods = "CTRL|SHIFT",
    action = wezterm.action.TogglePaneZoomState,
  },
}

-- Smart Splits (Neovim integration)
smart_splits.apply_to_config(config)

-- Modal (Zellij-like modes with hint status bar)
modal.apply_to_config(config)

-- Enter-mode keybindings (Alt+n은 workspace 이동에 쓰고 있어서 Scroll은 Alt+p로)
table.insert(config.keys, {
  key = "u",
  mods = "ALT",
  action = modal.activate_mode("UI"),
})
table.insert(config.keys, {
  key = "c",
  mods = "ALT",
  action = modal.activate_mode("copy_mode"),
})
table.insert(config.keys, {
  key = "p",
  mods = "ALT",
  action = modal.activate_mode("Scroll"),
})

-- 모드 진입/종료 시 우측 상태바에 힌트 표시
wezterm.on("modal.enter", function(name, window, pane)
  modal.set_right_status(window, name)
  modal.set_window_title(pane, name)
end)
wezterm.on("modal.exit", function(name, window, pane)
  window:set_right_status("")
  modal.reset_window_title(pane)
end)

return config
