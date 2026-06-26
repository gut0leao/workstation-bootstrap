#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-false}"
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

executed=()
ignored=()
pending=()

info() {
  printf '[INFO] %s\n' "$1"
}

add_executed() {
  executed+=("$1")
}

add_ignored() {
  ignored+=("$1")
}

add_pending() {
  pending+=("$1")
}

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would run '$*'."
    return 0
  fi

  "$@"
}

can_sudo_noninteractive() {
  sudo -n true >/dev/null 2>&1
}

run_sudo() {
  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would run 'sudo $*'."
    return 0
  fi

  if ! can_sudo_noninteractive; then
    add_pending "sudo is required for '$*' but is not available non-interactively."
    return 1
  fi

  sudo -n "$@"
}

timestamp() {
  date '+%Y%m%d-%H%M%S'
}

backup_file() {
  local path="$1"
  local reason="$2"

  if [[ ! -e "$path" ]]; then
    return 0
  fi

  local backup_path="${path}.backup-$(timestamp)"

  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would create backup '$backup_path' before $reason."
    return 0
  fi

  cp "$path" "$backup_path"
  add_executed "Created backup '$backup_path'."
}

copy_config_file() {
  local name="$1"
  local source_path="$2"
  local target_path="$3"

  if [[ ! -f "$source_path" ]]; then
    add_pending "Source config not found: $source_path"
    return 1
  fi

  if [[ -f "$target_path" ]] && cmp -s "$source_path" "$target_path"; then
    add_ignored "$name is already up to date."
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    add_pending "DryRun: would apply $name to '$target_path'."
    [[ -f "$target_path" ]] && add_pending "DryRun: would create timestamped backup before replacing '$target_path'."
    return 0
  fi

  mkdir -p "$(dirname "$target_path")"
  backup_file "$target_path" "replacing $name"
  cp "$source_path" "$target_path"
  add_executed "Applied $name to '$target_path'."
}

print_summary() {
  printf '\nSummary\n'
  printf '%s\n' '-------'

  printf 'Executed:\n'
  if [[ "${#executed[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    printf '  - %s\n' "${executed[@]}"
  fi

  printf 'Ignored:\n'
  if [[ "${#ignored[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    printf '  - %s\n' "${ignored[@]}"
  fi

  printf 'Pending:\n'
  if [[ "${#pending[@]}" -eq 0 ]]; then
    printf '  - none\n'
  else
    printf '  - %s\n' "${pending[@]}"
  fi
}
