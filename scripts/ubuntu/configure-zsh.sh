#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

configure_zsh() {
  local source_path="$PROJECT_ROOT/config/zsh/.zshrc"
  local target_path="$HOME/.zshrc"

  copy_config_file ".zshrc" "$source_path" "$target_path"

  if ! command -v zsh >/dev/null 2>&1; then
    add_pending "zsh is not installed; install Ubuntu packages first."
    return 0
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    add_ignored "Default shell is already zsh."
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would change default shell to '$zsh_path'."
    return 0
  fi

  if ! can_sudo_noninteractive; then
    add_pending "sudo is required to change the default shell non-interactively."
    add_pending "Run manually inside Ubuntu: chsh -s $zsh_path"
    return 0
  fi

  if sudo -n chsh -s "$zsh_path" "$USER"; then
    add_executed "Changed default shell to '$zsh_path'."
  else
    add_pending "Could not change default shell automatically; run 'chsh -s $zsh_path'."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
  done

  configure_zsh
  print_summary
fi
