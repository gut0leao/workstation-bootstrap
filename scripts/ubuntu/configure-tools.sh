#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

configure_tools() {
  local required_commands=(zoxide fzf rg btop direnv)

  for command_name in "${required_commands[@]}"; do
    if command -v "$command_name" >/dev/null 2>&1; then
      add_ignored "Tool '$command_name' is available."
    else
      add_pending "Tool '$command_name' is not available yet."
    fi
  done

  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    add_ignored "Tool 'bat' is available."
  else
    add_pending "Tool 'bat' is not available yet."
  fi

  if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
    add_ignored "Tool 'fd' is available."
  else
    add_pending "Tool 'fd' is not available yet."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
  done

  configure_tools
  print_summary
fi
