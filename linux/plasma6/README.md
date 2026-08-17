# Move Mouse for CachyOS / KDE Plasma 6

This directory contains the KDE Plasma 6 edition of Move Mouse for CachyOS and other Arch-based distributions. It preserves the familiar Move Mouse interaction while working correctly in a Plasma Wayland session.

## Windows-style Move Mouse experience

- Circular Move Mouse control with the **original Move Mouse mouse mascot** in the centre when installed from the repository.
- The green play triangle is centred on the mascot.
- Click the mouse itself to Start/Stop.
- Circular countdown ring while running.
- **Real keyboard/mouse activity resets the countdown**. Move Mouse only executes after the configured period of continuous inactivity.
- Green running state, orange execution state, yellow scheduled state and purple blackout state.
- Optional status text inside the circular control.
- Right-click the widget and choose **Configure Move Mouse…** for the settings window.
- Right-click also provides quick **Start/Stop Move Mouse** and **Test actions now** commands.

The installer stages the original `Move Mouse/Resources/Mouse.ico` asset into the Plasma package. A built-in SVG mascot is retained as a fallback.

## How activity detection works on Wayland

KDE's Wayland idle backend is event-driven rather than pollable. The Plasma edition therefore installs a tiny native helper built against KDE Frameworks `KIdleTime`.

The helper waits for KDE's idle and resume events:

1. While you are moving the mouse or typing, the countdown remains reset.
2. After a very short quiet period, the configured countdown begins.
3. Any real keyboard/mouse input immediately resets the countdown.
4. When the full interval is reached, the configured Move Mouse actions run.

This avoids relying on X11-only idle APIs or the unsupported Wayland `GetSessionIdleTime` polling path.

## Settings

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

Runtime:

- KDE Plasma 6.
- `ydotool` and its user service.
- KDE Frameworks `kidletime`.

The installer also compiles the small idle-event helper, so the following build packages are required once:

- `cmake`
- `extra-cmake-modules`
- `gcc`

On CachyOS/Arch Linux:

```bash
sudo pacman -S --needed ydotool kidletime cmake extra-cmake-modules gcc
systemctl --user enable --now ydotool.service
```

## Install / upgrade

From the repository root:

```bash
bash linux/plasma6/install-cachyos.sh
```

The installer:

- builds and installs `~/.local/libexec/movemouse/movemouse-idle-monitor`;
- upgrades the Plasma widget;
- stages the original Windows mouse artwork into the widget package.

Then restart Plasma Shell after an upgrade:

```bash
systemctl --user restart plasma-plasmashell.service
```

If Plasma keeps an old widget instance cached, remove Move Mouse from the panel/desktop and add it again.

## Add the widget

1. Right-click the KDE Plasma panel or desktop.
2. Choose **Add Widgets…**.
3. Search for **Move Mouse**.
4. Add it to the panel or desktop.
5. Click the circular mouse control to start or stop it.
6. Right-click the widget and choose **Configure Move Mouse…**.

## Troubleshooting

Check the simulated input backend:

```bash
ydotool --help
systemctl --user status ydotool.service
ydotool mousemove -x 5 -y 0
```

Check that the KDE idle helper was installed:

```bash
ls -l ~/.local/libexec/movemouse/movemouse-idle-monitor
```

Test idle detection by running the following and then not touching the keyboard or mouse for three seconds. The command should exit after the idle timeout:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-idle 3000
```

Test resume detection by running the following, then moving the mouse after it starts. The command should exit on activity:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-activity
```

If direct input fails, inspect `/dev/uinput` permissions and the ydotool service logs:

```bash
journalctl --user -u ydotool.service -b
```

## Remove

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
rm -f ~/.local/libexec/movemouse/movemouse-idle-monitor
```

## Source layout

```text
linux/plasma6/
├── idle-monitor/
│   ├── CMakeLists.txt
│   └── main.cpp
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
