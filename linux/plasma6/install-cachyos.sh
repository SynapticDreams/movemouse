#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/org.movemouse.plasma"
PACKAGE_ID="org.movemouse.plasma"
ORIGINAL_ICON="$REPO_ROOT/Move Mouse/Resources/Mouse.ico"

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

# Stage the package so the Plasma edition can reuse the original Windows
# Move Mouse mascot without duplicating a binary asset in this Linux tree.
STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT
cp -a "$PACKAGE_DIR/." "$STAGE_DIR/"
mkdir -p "$STAGE_DIR/contents/images"

if [[ -f "$ORIGINAL_ICON" ]]; then
  cp "$ORIGINAL_ICON" "$STAGE_DIR/contents/images/mouse.ico"
else
  echo "Warning: original Move Mouse icon was not found; the SVG fallback mascot will be used." >&2
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
  if kpackagetool6 --type Plasma/Applet --show "$PACKAGE_ID" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$STAGE_DIR"
  else
    kpackagetool6 --type Plasma/Applet --install "$STAGE_DIR"
  fi
else
  if plasmapkg2 --show "$PACKAGE_ID" >/dev/null 2>&1; then
    plasmapkg2 --upgrade "$STAGE_DIR"
  else
    plasmapkg2 --install "$STAGE_DIR"
  fi
fi

echo
echo "Move Mouse has been installed for the current user."
echo "The Plasma widget is using the original Move Mouse mascot when available."
echo "Right-click your KDE Plasma panel or desktop, choose 'Add Widgets...',"
echo "search for 'Move Mouse', and add it to your panel or desktop."
echo "Right-click the widget itself and choose 'Configure Move Mouse...' for settings."
