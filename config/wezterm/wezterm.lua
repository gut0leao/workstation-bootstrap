local wezterm = require 'wezterm'

local config = {}
local act = wezterm.action

local function url_decode(value)
  return (value:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function current_dir_for_wsl(pane)
  local cwd_uri = pane:get_current_working_dir()

  if cwd_uri == nil then
    return "~"
  end

  local cwd = tostring(cwd_uri)
  local unix_path = cwd:match("^file://[^/]+(/.*)$")

  if unix_path ~= nil then
    return url_decode(unix_path)
  end

  local drive, windows_path = cwd:match("^file:///([A-Za-z]):/(.*)$")

  if drive ~= nil and windows_path ~= nil then
    return "/mnt/" .. drive:lower() .. "/" .. url_decode(windows_path)
  end

  return "~"
end

wezterm.on("spawn-ubuntu-tab-in-current-dir", function(window, pane)
  window:perform_action(
    act.SpawnCommandInNewTab {
      args = { "wsl.exe", "-d", "Ubuntu", "--cd", current_dir_for_wsl(pane) },
      domain = { DomainName = "local" },
    },
    pane
  )
end)

-- Shell padrão: abre o Ubuntu via wsl.exe.
-- O .zshrc publica o cwd via OSC 7 para permitir abrir novas abas no mesmo diretório.
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
    domain = { DomainName = "local" },
  },
  {
    label = "Command Prompt",
    args = { "cmd.exe" },
    domain = { DomainName = "local" },
  },
}

-- Atalhos
config.keys = {
  {
    key = "P",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "powershell.exe", "-NoLogo" },
      domain = { DomainName = "local" },
    },
  },
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = act.CopyTo "Clipboard",
  },
  {
    key = "D",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab {
      args = { "cmd.exe" },
      domain = { DomainName = "local" },
    },
  },
  {
    key = "U",
    mods = "CTRL|SHIFT",
    action = act.EmitEvent "spawn-ubuntu-tab-in-current-dir",
  },
}

return config
