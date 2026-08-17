# Move Mouse for CachyOS / KDE Plasma 6

This directory contains a KDE Plasma 6 widget for Move Mouse. It is designed for CachyOS and other Arch-based distributions running KDE Plasma 6, including Wayland sessions.

## Features

- Native Plasma panel/desktop widget.
- One-click Start/Stop control.
- Configurable movement interval (5–3600 seconds).
- Configurable movement distance (1–50 pixels).
- Alternates left/right movement so the pointer stays close to its original location.
- Uses `ydotool`/Linux `uinput`, so it works under Wayland rather than relying on X11-only pointer APIs.
- Keeps the existing Windows/WPF application untouched.

## Requirements

- KDE Plasma 6.
- `ydotool`.
- The `ydotool` user service (`ydotoold`) running.

On CachyOS/Arch Linux:

```bash
sudo pacman -S ydotool
systemctl --user enable --now ydotool.service
```

The Arch package includes `ydotool`, `ydotoold`, a user systemd service, and the udev rule required for `/dev/uinput` access.

## Install

From the repository root:

```bash
bash linux/plasma6/install-cachyos.sh
```

Then:

1. Right-click the KDE Plasma panel or desktop.
2. Choose **Add Widgets…**.
3. Search for **Move Mouse**.
4. Add it to the panel or desktop.
5. Click the mouse icon to start/stop movement.
6. Right-click the widget and choose **Configure Move Mouse…** to change the interval or movement distance.

## Manual install

```bash
kpackagetool6 --type Plasma/Applet --install linux/plasma6/org.movemouse.plasma
```

To upgrade an existing installation:

```bash
kpackagetool6 --type Plasma/Applet --upgrade linux/plasma6/org.movemouse.plasma
```

To remove it:

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
```

## Wayland notes

KDE Plasma Wayland does not allow an ordinary application to arbitrarily warp the user's pointer through legacy X11 APIs. This implementation therefore uses `ydotool`, which injects input through Linux's `uinput` subsystem. That makes the movement visible to Wayland applications and Plasma itself.

The widget currently uses Plasma's executable data engine compatibility module to launch the local `ydotool` command. The visual/widget structure itself targets Plasma 6 (`X-Plasma-API-Minimum-Version: 6.0`).

## Troubleshooting

Check that `ydotool` is installed:

```bash
ydotool --help
```

Check the daemon:

```bash
systemctl --user status ydotool.service
```

Test pointer movement directly:

```bash
ydotool mousemove -x 5 -y 0
```

If direct movement fails, inspect `/dev/uinput` permissions and the service logs:

```bash
journalctl --user -u ydotool.service -b
```

After modifying QML files during development, restart Plasma Shell if necessary:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Source layout

```text
linux/plasma6/
├── install-cachyos.sh
├── README.md
└── org.movemouse.plasma/
    ├── metadata.json
    └── contents/
        ├── config/
        │   ├── config.qml
        │   └── main.xml
        └── ui/
            ├── ConfigGeneral.qml
            └── main.qml
```
