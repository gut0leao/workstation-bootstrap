#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

install_starship_if_needed() {
  if command -v starship >/dev/null 2>&1; then
    add_ignored "Starship is already installed."
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would install Starship using the official install script."
    return 0
  fi

  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  add_executed "Installed Starship."
}

configure_starship() {
  install_starship_if_needed

  local source_path="$PROJECT_ROOT/config/starship/starship.toml"
  local target_path="$HOME/.config/starship.toml"

  copy_config_file "Starship config" "$source_path" "$target_path"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
  done

  configure_starship
  print_summary
fi
