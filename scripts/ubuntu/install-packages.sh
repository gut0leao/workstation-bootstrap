#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

install_ubuntu_packages() {
  local packages_file="$PROJECT_ROOT/packages/ubuntu.txt"

  if [[ ! -f "$packages_file" ]]; then
    add_pending "Ubuntu package list not found: $packages_file"
    return 1
  fi

  mapfile -t packages < <(grep -Ev '^\s*(#|$)' "$packages_file")

  if [[ "${#packages[@]}" -eq 0 ]]; then
    add_ignored "No Ubuntu packages declared."
    return 0
  fi

  local missing=()

  for package in "${packages[@]}"; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
      add_ignored "Ubuntu package '$package' is already installed."
    else
      missing+=("$package")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would install Ubuntu packages: ${missing[*]}."
    return 0
  fi

  if ! can_sudo_noninteractive; then
    add_pending "sudo is required to install Ubuntu packages but is not available non-interactively."
    add_pending "Run manually inside Ubuntu: sudo apt-get update && sudo apt-get install -y ${missing[*]}"
    return 0
  fi

  sudo -n apt-get update
  sudo -n apt-get install -y "${missing[@]}"
  add_executed "Installed Ubuntu packages: ${missing[*]}."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
  done

  install_ubuntu_packages
  print_summary
fi
