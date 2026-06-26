#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=install-packages.sh
source "$SCRIPT_DIR/install-packages.sh"
# shellcheck source=configure-git.sh
source "$SCRIPT_DIR/configure-git.sh"
# shellcheck source=configure-starship.sh
source "$SCRIPT_DIR/configure-starship.sh"
# shellcheck source=configure-tools.sh
source "$SCRIPT_DIR/configure-tools.sh"
# shellcheck source=configure-zsh.sh
source "$SCRIPT_DIR/configure-zsh.sh"

skip_ubuntu_packages=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --skip-ubuntu-packages)
      skip_ubuntu_packages=true
      ;;
    *)
      add_pending "Unknown Ubuntu bootstrap argument ignored: $arg"
      ;;
  esac
done

info "Starting workstation-bootstrap Ubuntu bootstrap."

if [[ "$skip_ubuntu_packages" == "true" ]]; then
  add_ignored "Skipped Ubuntu package installation because --skip-ubuntu-packages was provided."
else
  install_ubuntu_packages
fi

configure_git
configure_starship
configure_zsh
configure_tools

print_summary
