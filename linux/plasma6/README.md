# Move Mouse for CachyOS / KDE Plasma 6

This directory contains the KDE Plasma 6 edition of Move Mouse for CachyOS and other Arch-based distributions. It preserves the familiar Move Mouse interaction while working correctly in a Plasma Wayland session.

> **Development status:** the Plasma edition is currently under active testing in Draft PR #1 on branch `agent/cachyos-kde-plasma-widget`.

## Features

- Circular Move Mouse control with the **original Move Mouse mouse mascot** in the centre when installed from the repository.
- Green play triangle centred on the mascot while stopped.
- Click the mouse itself to Start/Stop.
- Circular countdown ring while running.
- **Real keyboard/mouse activity resets the countdown**.
- Move Mouse executes only after the configured period of continuous inactivity.
- Green running state, orange execution state, yellow scheduled state and purple blackout state.
- Optional status text inside the circular control.
- Right-click the widget and choose **Configure Move Mouse…** for settings.
- Right-click also provides **Start/Stop Move Mouse** and **Test actions now**.

The installer stages the original `Move Mouse/Resources/Mouse.ico` asset into the Plasma package. A built-in SVG mascot is retained as a fallback.

## How activity detection works on Wayland

KDE's Wayland idle backend is event-driven rather than relying on legacy X11 idle polling. The Plasma edition therefore installs a small native helper built against KDE Frameworks `KIdleTime`.

The helper waits for KDE's idle and resume events:

1. While you are moving the mouse or typing, the countdown remains reset.
2. When you stop using the computer, the configured countdown begins.
3. Any genuine keyboard/mouse input immediately resets the countdown.
4. When the full interval is reached, the configured Move Mouse actions run.
5. Move Mouse then waits for the next continuous inactivity period.

## Requirements

Runtime:

- KDE Plasma 6.
- CachyOS or another Arch-based Linux distribution.
- `ydotool` and its user service.
- KDE Frameworks `kidletime`.

The installer compiles the small idle-event helper, so these build packages are also required:

- `cmake`
- `extra-cmake-modules`
- `gcc`

Install everything required on CachyOS/Arch:

```bash
sudo pacman -S --needed ydotool kidletime cmake extra-cmake-modules gcc
```

Enable the input service:

```bash
systemctl --user enable --now ydotool.service
```

Confirm it is running:

```bash
systemctl --user status ydotool.service
```

## First-time installation

Clone the repository:

```bash
git clone https://github.com/SynapticDreams/movemouse.git
cd movemouse
```

While Draft PR #1 is still in development, switch to the Plasma branch:

```bash
git switch agent/cachyos-kde-plasma-widget
```

Once the work is merged into `master`, this branch-switch step can be skipped.

Install dependencies and start `ydotool`:

```bash
sudo pacman -S --needed ydotool kidletime cmake extra-cmake-modules gcc
systemctl --user enable --now ydotool.service
```

Install the widget:

```bash
bash linux/plasma6/install-cachyos.sh
```

The installer will:

- build the KIdleTime helper;
- install it to `~/.local/libexec/movemouse/movemouse-idle-monitor`;
- stage the original Windows Move Mouse mascot into the Plasma package;
- install or upgrade `org.movemouse.plasma` for the current user.

Restart Plasma Shell after installing/upgrading:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Add the widget

1. Right-click the KDE Plasma panel or desktop.
2. Choose **Add Widgets…**.
3. Search for **Move Mouse**.
4. Add it to the panel or desktop.
5. Click the circular mouse control to start or stop it.
6. Right-click the widget and choose **Configure Move Mouse…** for configuration.

## Settings

### Actions

Configure what happens when the inactivity period expires:

- Enable/disable pointer movement.
- Movement distance.
- Horizontal, vertical, diagonal, square or random movement.
- Optional left, right or middle mouse click after movement.

### Behaviour

- Fixed inactivity interval.
- Random interval between minimum and maximum values.
- Automatically start actions when the widget loads.

A setting of `30` seconds means Move Mouse waits for **30 uninterrupted seconds without real keyboard/mouse activity** before executing.

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

## Updating

While development remains on the feature branch:

```bash
cd movemouse
git switch agent/cachyos-kde-plasma-widget
git pull
bash linux/plasma6/install-cachyos.sh
systemctl --user restart plasma-plasmashell.service
```

After the Plasma edition is merged into `master`:

```bash
cd movemouse
git switch master
git pull
bash linux/plasma6/install-cachyos.sh
systemctl --user restart plasma-plasmashell.service
```

If Plasma retains an older cached widget instance, remove Move Mouse from the panel/desktop and add it again.

## Testing activity detection

Confirm the helper exists:

```bash
ls -l ~/.local/libexec/movemouse/movemouse-idle-monitor
```

### Test idle detection

Run:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-idle 3000
```

Do not touch the keyboard or mouse. The command should exit after roughly three seconds of inactivity.

### Test activity/resume detection

Run:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-activity
```

Then move the mouse or press a key. The command should exit immediately when KDE reports activity.

### Test the widget itself

A useful functional test is:

1. Configure a 30-second interval.
2. Start Move Mouse.
3. Leave the computer untouched for around 10 seconds.
4. Move the mouse or press a key.
5. Confirm the countdown ring returns to full.
6. Continue using the computer for longer than 30 seconds; Move Mouse should not execute.
7. Stop all keyboard/mouse input for 30 uninterrupted seconds; Move Mouse should execute once the countdown finishes.

## Troubleshooting

### Mouse does not move

Check `ydotool`:

```bash
ydotool --help
systemctl --user status ydotool.service
```

Restart its service if needed:

```bash
systemctl --user restart ydotool.service
```

Test pointer movement directly:

```bash
ydotool mousemove -x 5 -y 0
```

Test a left click:

```bash
ydotool click 0xC0
```

Inspect service logs:

```bash
journalctl --user -u ydotool.service -b
```

If direct `ydotool` commands fail, troubleshoot `/dev/uinput` permissions or the `ydotool` service before the Plasma widget.

### Countdown does not reset with real activity

Verify the helper exists:

```bash
ls -l ~/.local/libexec/movemouse/movemouse-idle-monitor
```

Run both helper tests above. If the helper is missing or does not run, reinstall dependencies and rerun the installer:

```bash
sudo pacman -S --needed kidletime cmake extra-cmake-modules gcc
bash linux/plasma6/install-cachyos.sh
```

### Widget does not appear in Add Widgets

Check whether Plasma sees the package:

```bash
kpackagetool6 --type Plasma/Applet --show org.movemouse.plasma
```

Rerun the installer:

```bash
bash linux/plasma6/install-cachyos.sh
```

Then restart Plasma Shell:

```bash
systemctl --user restart plasma-plasmashell.service
```

### Widget still looks like an old version

Plasma can retain a cached widget instance. Try:

```bash
systemctl --user restart plasma-plasmashell.service
```

If necessary:

1. Remove Move Mouse from the panel/desktop.
2. Rerun `bash linux/plasma6/install-cachyos.sh`.
3. Restart Plasma Shell.
4. Add Move Mouse again through **Add Widgets…**.

## Uninstall

Remove the Plasma package:

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
```

Remove the KIdleTime helper:

```bash
rm -f ~/.local/libexec/movemouse/movemouse-idle-monitor
```

Optionally stop and disable `ydotool` if nothing else on your computer uses it:

```bash
systemctl --user disable --now ydotool.service
```

Do not blindly remove KDE packages such as `kidletime`; they may be dependencies of other Plasma components.

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
