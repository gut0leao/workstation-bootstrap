#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

configure_git() {
  if ! command -v git >/dev/null 2>&1; then
    add_pending "git is not installed; install Ubuntu packages first."
    return 0
  fi

  local current_default_branch
  current_default_branch="$(git config --global --get init.defaultBranch || true)"

  if [[ "$current_default_branch" == "main" ]]; then
    add_ignored "Git init.defaultBranch is already main."
  elif [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would set Git init.defaultBranch to main."
  else
    git config --global init.defaultBranch main
    add_executed "Set Git init.defaultBranch to main."
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
  done

  configure_git
  print_summary
fi
