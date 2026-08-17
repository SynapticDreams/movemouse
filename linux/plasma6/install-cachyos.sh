#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/org.movemouse.plasma"
PACKAGE_ID="org.movemouse.plasma"
ORIGINAL_ICON="$REPO_ROOT/Move Mouse/Resources/Mouse.ico"
IDLE_MONITOR_SOURCE="$SCRIPT_DIR/idle-monitor"
IDLE_MONITOR_DEST="$HOME/.local/libexec/movemouse/movemouse-idle-monitor"

if ! command -v plasmapkg2 >/dev/null 2>&1 && ! command -v kpackagetool6 >/dev/null 2>&1; then
  echo "KDE Plasma 6 package tools were not found. Install Plasma 6 first." >&2
  exit 1
fi

if ! command -v ydotool >/dev/null 2>&1; then
  echo "ydotool is required for Wayland mouse movement."
  echo "On CachyOS/Arch, install it with: sudo pacman -S ydotool"
  exit 1
fi

# The native helper uses KDE's KIdleTime event API so real keyboard/mouse
# activity resets the Move Mouse countdown correctly on Plasma Wayland.
missing_packages=()
for package in kidletime cmake extra-cmake-modules gcc; do
  if ! pacman -Q "$package" >/dev/null 2>&1; then
    missing_packages+=("$package")
  fi
done

if ((${#missing_packages[@]} > 0)); then
  echo "Additional packages are required to build the KDE activity monitor:"
  printf '  %s\n' "${missing_packages[@]}"
  echo
  echo "Install them with:"
  echo "  sudo pacman -S --needed ${missing_packages[*]}"
  echo
  echo "Then run this installer again."
  exit 1
fi

if systemctl --user list-unit-files ydotool.service >/dev/null 2>&1; then
  systemctl --user enable --now ydotool.service || {
    echo "Could not start ydotool.service automatically."
    echo "Try: systemctl --user enable --now ydotool.service"
    exit 1
  }
fi

STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

# Build the very small event-driven KIdleTime helper. It does not poll idle
# time (which is unsupported by KIdleTime on Wayland); it waits for KDE's
# native idle/resume events instead.
BUILD_DIR="$STAGE_DIR/idle-monitor-build"
cmake -S "$IDLE_MONITOR_SOURCE" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD_DIR" --parallel
install -Dm755 "$BUILD_DIR/movemouse-idle-monitor" "$IDLE_MONITOR_DEST"

# Stage the package so the Plasma edition can reuse the original Windows
# Move Mouse mascot without duplicating a binary asset in this Linux tree.
mkdir -p "$STAGE_DIR/package"
cp -a "$PACKAGE_DIR/." "$STAGE_DIR/package/"
mkdir -p "$STAGE_DIR/package/contents/images"

if [[ -f "$ORIGINAL_ICON" ]]; then
  cp "$ORIGINAL_ICON" "$STAGE_DIR/package/contents/images/mouse.ico"
else
  echo "Warning: original Move Mouse icon was not found; the SVG fallback mascot will be used." >&2
fi

if command -v kpackagetool6 >/dev/null 2>&1; then
  if kpackagetool6 --type Plasma/Applet --show "$PACKAGE_ID" >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$STAGE_DIR/package"
  else
    kpackagetool6 --type Plasma/Applet --install "$STAGE_DIR/package"
  fi
else
  if plasmapkg2 --show "$PACKAGE_ID" >/dev/null 2>&1; then
    plasmapkg2 --upgrade "$STAGE_DIR/package"
  else
    plasmapkg2 --install "$STAGE_DIR/package"
  fi
fi

echo
echo "Move Mouse has been installed for the current user."
echo "The Plasma widget is using the original Move Mouse mascot when available."
echo "KDE keyboard/mouse activity detection is installed at:"
echo "  $IDLE_MONITOR_DEST"
echo "Right-click your KDE Plasma panel or desktop, choose 'Add Widgets...',"
echo "search for 'Move Mouse', and add it to your panel or desktop."
echo "Right-click the widget itself and choose 'Configure Move Mouse...' for settings."
