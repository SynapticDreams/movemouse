# Move Mouse for CachyOS / KDE Plasma 6

This directory contains the KDE Plasma 6 edition of Move Mouse for CachyOS and other Arch-based distributions. It is designed to preserve the familiar Move Mouse interaction while working correctly in a Plasma Wayland session.

## Windows-style Move Mouse experience

The Plasma edition now follows the original Windows `MouseWindow` design rather than using a generic Plasma button:

- Circular Move Mouse control with the mouse mascot in the centre.
- Click the mouse itself to Start/Stop.
- Green play badge while idle.
- Circular countdown ring while running.
- Green running state, orange execution state, yellow scheduled state and purple blackout state.
- Optional status text inside the circular control.
- Right-click the widget and choose **Configure Move Mouse…** for the settings window.
- Right-click also provides quick **Start/Stop Move Mouse** and **Test actions now** commands.

## Settings

The configuration window mirrors the major sections of the Windows application:

### Actions

- Enable/disable pointer movement.
- Movement distance.
- Horizontal, vertical, diagonal, square or random movement.
- Optional left, right or middle mouse click after movement.

### Behaviour

- Fixed repeat interval.
- Random interval between minimum and maximum values.
- Automatically start actions when the widget loads.

### Appearance

- Show/hide status text.
- Show/hide the countdown ring.
- Enable/disable execution animation.
- Configure ring thickness.

### Schedules

- Enable a working-hours schedule.
- Choose start/end times.
- Choose active days of the week.
- Overnight schedules are supported.

### Blackouts

- Pause simulated input during a configured blackout window.
- Choose blackout start/end times and days.
- The circular ring changes to purple while a blackout is active.

## Requirements

- KDE Plasma 6.
- `ydotool`.
- The `ydotool` user service (`ydotoold`) running.

On CachyOS/Arch Linux:

```bash
sudo pacman -S ydotool
systemctl --user enable --now ydotool.service
```

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
5. Click the circular mouse control to start or stop it.
6. Right-click the widget and choose **Configure Move Mouse…** to access Actions, Behaviour, Appearance, Schedules and Blackouts.

## Upgrade an existing test installation

If you installed the earlier version from this branch, update the repository and run:

```bash
git pull
kpackagetool6 --type Plasma/Applet --upgrade linux/plasma6/org.movemouse.plasma
systemctl --user restart plasma-plasmashell.service
```

If Plasma keeps a cached copy of the previous widget, remove and reinstall it:

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
kpackagetool6 --type Plasma/Applet --install linux/plasma6/org.movemouse.plasma
systemctl --user restart plasma-plasmashell.service
```

## Manual install

```bash
kpackagetool6 --type Plasma/Applet --install linux/plasma6/org.movemouse.plasma
```

To remove it:

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
```

## Wayland notes

KDE Plasma Wayland does not allow an ordinary application to arbitrarily warp the user's pointer through legacy X11 APIs. This implementation uses `ydotool`, which injects input through Linux's `uinput` subsystem, so the simulated movement/click is visible to Wayland applications and Plasma itself.

The widget uses Plasma's executable data-engine compatibility module to launch the local `ydotool` commands. The visual/widget structure itself targets Plasma 6 (`X-Plasma-API-Minimum-Version: 6.0`).

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

Test a left click:

```bash
ydotool click 0xC0
```

If direct input fails, inspect `/dev/uinput` permissions and the service logs:

```bash
journalctl --user -u ydotool.service -b
```

## Source layout

```text
linux/plasma6/
├── install-cachyos.sh
├── README.md
└── org.movemouse.plasma/
    ├── metadata.json
    └── contents/
        ├── images/
        │   └── mouse.svg
        ├── config/
        │   ├── config.qml
        │   └── main.xml
        └── ui/
            ├── ConfigActions.qml
            ├── ConfigAppearance.qml
            ├── ConfigBehaviour.qml
            ├── ConfigBlackouts.qml
            ├── ConfigSchedules.qml
            ├── MouseFace.qml
            └── main.qml
```
