#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/org.movemouse.plasma"
PACKAGE_ID="org.movemouse.plasma"

if ! command -v plasmapkg2 >/dev/null 2>&1 && ! command -v kpackagetool6 >/dev/null 2>&1; then
  echo "KDE Plasma 6 package tools were not found. Install Plasma 6 first." >&2
  exit 1
fi

if ! command -v ydotool >/dev/null 2>&1; then
  echo "ydotool is required for Wayland mouse movement."
  echo "On CachyOS/Arch, install it with: sudo pacman -S ydotool"
  exit 1
fi

if systemctl --user list-unit-files ydotool.service >/dev/null 2>&1; then
  systemctl --user enable --now ydotool.service || {
    echo "Could not start ydotool.service automatically."
    echo "Try: systemctl --user enable --now ydotool.service"
    exit 1
  }
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
  if kpackagetool6 --type Plasma/Applet --show "$PACKAGE_ID" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$PACKAGE_DIR"
  else
    kpackagetool6 --type Plasma/Applet --install "$PACKAGE_DIR"
  fi
else
  if plasmapkg2 --show "$PACKAGE_ID" >/dev/null 2>&1; then
    plasmapkg2 --upgrade "$PACKAGE_DIR"
  else
    plasmapkg2 --install "$PACKAGE_DIR"
  fi
fi

echo
echo "Move Mouse has been installed for the current user."
echo "Right-click your KDE Plasma panel or desktop, choose 'Add Widgets...',"
echo "search for 'Move Mouse', and add it to your panel."
