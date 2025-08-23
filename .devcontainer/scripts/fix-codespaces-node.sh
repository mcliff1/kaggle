#!/usr/bin/env bash
set -euo pipefail

fix_home() {
  local HOME_DIR="$1"
  if [ -d "$HOME_DIR" ]; then
    if [ -d "$HOME_DIR/.vscode-server" ] && [ ! -e "$HOME_DIR/.vscode-remote" ]; then
      ln -sfn "$HOME_DIR/.vscode-server" "$HOME_DIR/.vscode-remote"
    fi
  fi
}

fix_home "/root"
fix_home "/home/vscode"
fix_home "/home/codespace"