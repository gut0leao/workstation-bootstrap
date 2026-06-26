local wezterm = require 'wezterm'

local config = {}
local act = wezterm.action

-- Shell padrão: abre o Ubuntu via wsl.exe
-- Importante: não usar default_domain aqui, para não forçar PowerShell/CMD dentro do WSL
config.default_prog = { "wsl.exe", "-d", "Ubuntu", "--cd", "~" }

-- Aparência
config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.92
config.win32_system_backdrop = "Acrylic"

-- Fonte
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12

-- Espaçamento
config.window_padding = {
  left = 12,
  right = 12,
  top = 10,
  bottom = 10,
}

-- Scrollback
config.scrollback_lines = 20000

-- Menu para abrir outros shells
config.launch_menu = {
  {
    label = "Ubuntu / WSL",
    args = { "wsl.exe", "-d", "Ubuntu", "--cd", "~" },
  },
  {
    label = "PowerShell",
    args = { "powershell.exe", "-NoLogo" },
  },
  {
    label = "Command Prompt",
    args = { "cmd.exe" },
  },
}

-- Atalhos
config.keys = {
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "powershell.exe", "-NoLogo" },
    },
  },
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "cmd.exe" },
    },
  },
  {
    key = "U",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "wsl.exe", "-d", "Ubuntu" },
    },
  },
}

return config