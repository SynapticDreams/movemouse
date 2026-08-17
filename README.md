# Move Mouse

Move Mouse is a simple application designed to simulate user activity. It was originally created for Windows to help prevent a user session from locking or the computer from going to sleep.

This fork also includes a **KDE Plasma 6 edition for CachyOS and other Arch-based Linux distributions**, with support for Plasma Wayland.

<img src="Images/mm_blue.png" width="200" alt="Move Mouse mascot">

## Platforms

| Platform | Status | Interface |
| --- | --- | --- |
| Windows | Original application | Windows/WPF application |
| CachyOS / Arch Linux | Active development/testing | KDE Plasma 6 widget |
| KDE Plasma Wayland | Supported by Linux edition | `ydotool` + KDE `KIdleTime` |
| X11 | Linux widget may work, but Wayland is the primary target | KDE Plasma 6 widget |

The original Windows source is left intact. The Linux implementation lives under [`linux/plasma6/`](linux/plasma6/).

---

# CachyOS / KDE Plasma 6

## What the Plasma widget does

The Plasma edition follows the familiar Move Mouse design and behaviour:

- Circular Move Mouse control with the original mouse mascot.
- Click the mouse to **Start/Stop**.
- Green play triangle when stopped.
- Circular countdown ring while running.
- Real keyboard and mouse activity resets the countdown.
- Move Mouse only executes after the configured period of **continuous inactivity**.
- Green running state, orange execution state, yellow scheduled state and purple blackout state.
- Right-click the widget to access **Configure Move Mouse…**.
- Right-click also provides **Start/Stop Move Mouse** and **Test actions now**.

## Requirements

The Linux edition currently targets:

- CachyOS or another Arch-based Linux distribution.
- KDE Plasma 6.
- Plasma Wayland as the primary supported session.

Runtime/build dependencies:

```bash
sudo pacman -S --needed ydotool kidletime cmake extra-cmake-modules gcc
```

Enable the `ydotool` user service:

```bash
systemctl --user enable --now ydotool.service
```

You can confirm it is running with:

```bash
systemctl --user status ydotool.service
```

## First-time installation

Clone the repository:

```bash
git clone https://github.com/SynapticDreams/movemouse.git
cd movemouse
```

### While the KDE edition is still in Draft PR #1

The Plasma edition is currently being developed on:

```text
agent/cachyos-kde-plasma-widget
```

Check out that branch before installing:

```bash
git switch agent/cachyos-kde-plasma-widget
```

Once the Plasma work has been merged into `master`, this branch-switch step will no longer be required.

Install the dependencies if you have not already done so:

```bash
sudo pacman -S --needed ydotool kidletime cmake extra-cmake-modules gcc
systemctl --user enable --now ydotool.service
```

Run the installer:

```bash
bash linux/plasma6/install-cachyos.sh
```

The installer will:

1. Check the required CachyOS/Arch packages.
2. Build the small KDE `KIdleTime` activity-monitor helper.
3. Install the helper to:

   ```text
   ~/.local/libexec/movemouse/movemouse-idle-monitor
   ```

4. Stage the original Move Mouse mascot from the Windows project into the Plasma package.
5. Install or upgrade the Plasma widget for the current user.

## Add Move Mouse to KDE Plasma

After installation:

1. Right-click the KDE Plasma **panel or desktop**.
2. Select **Add Widgets…**.
3. Search for **Move Mouse**.
4. Add it to the panel or desktop.
5. Click the mouse graphic to start Move Mouse.

If the widget does not immediately appear after installation, restart Plasma Shell:

```bash
systemctl --user restart plasma-plasmashell.service
```

Then open **Add Widgets…** again.

## Using Move Mouse

### Start / stop

Left-click the mouse in the circular widget.

When stopped, the widget shows the green play triangle. When running, the circular ring represents the inactivity countdown.

### User activity and the countdown

The Linux edition does **not** simply execute every 30 seconds regardless of what you are doing.

KDE's `KIdleTime` events are used to detect genuine user activity:

1. While you are moving the mouse or typing, the countdown remains reset.
2. When you stop using the computer, the configured countdown begins.
3. Moving the mouse or pressing a key resets the countdown immediately.
4. Move Mouse executes only after the full interval passes without real user activity.
5. After executing, it waits for the next inactivity period.

This behaviour is designed specifically for KDE Plasma Wayland, where traditional X11 idle/pointer APIs are not appropriate.

## Configure Move Mouse

Right-click the widget and select:

**Configure Move Mouse…**

The configuration is divided into the following sections.

### Actions

Configure what Move Mouse does when the inactivity interval expires:

- Enable/disable pointer movement.
- Movement distance.
- Horizontal movement.
- Vertical movement.
- Diagonal movement.
- Square movement pattern.
- Random movement.
- Optional mouse click after movement.
- Left, right or middle mouse button.

### Behaviour

Configure when actions are executed:

- Fixed inactivity interval.
- Random interval between a minimum and maximum value.
- Automatically start Move Mouse when the widget loads.

For example, a fixed interval of `30` seconds means Move Mouse runs only after **30 uninterrupted seconds of no real keyboard/mouse activity**.

### Appearance

Configure the circular widget:

- Show/hide status text.
- Show/hide countdown ring.
- Enable/disable execution animation.
- Ring thickness.

### Schedules

Limit Move Mouse to configured working hours:

- Enable/disable schedule.
- Start time.
- End time.
- Select active days of the week.
- Overnight time ranges are supported.

When outside the configured schedule, the widget uses the yellow scheduled state.

### Blackouts

Temporarily prevent generated input during selected periods:

- Enable/disable blackout period.
- Start time.
- End time.
- Select days of the week.

The widget turns purple while a blackout is active.

## Updating an existing installation

From the repository directory:

```bash
cd movemouse
git switch agent/cachyos-kde-plasma-widget
git pull
bash linux/plasma6/install-cachyos.sh
systemctl --user restart plasma-plasmashell.service
```

After the branch is eventually merged into `master`, use:

```bash
cd movemouse
git switch master
git pull
bash linux/plasma6/install-cachyos.sh
systemctl --user restart plasma-plasmashell.service
```

If Plasma still displays an old cached version, remove the Move Mouse widget from your panel/desktop and add it again.

## Testing activity detection

The installer creates:

```text
~/.local/libexec/movemouse/movemouse-idle-monitor
```

### Test idle detection

Run:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-idle 3000
```

Do not touch the keyboard or mouse. The command should exit after approximately three seconds of inactivity.

### Test activity/resume detection

Run:

```bash
~/.local/libexec/movemouse/movemouse-idle-monitor --wait-activity
```

Then move the mouse or press a key. The command should exit immediately when KDE reports activity.

### Practical widget test

For an easy test:

1. Configure a 30-second interval.
2. Start Move Mouse.
3. Leave the computer untouched for about 10 seconds.
4. Move the mouse.
5. Confirm the circular countdown returns to full.
6. Continue using the computer for longer than 30 seconds; Move Mouse should not fire.
7. Stop all keyboard/mouse activity for 30 uninterrupted seconds; Move Mouse should then execute.

## Troubleshooting

### Mouse does not move

Confirm `ydotool` is installed:

```bash
ydotool --help
```

Check its user service:

```bash
systemctl --user status ydotool.service
```

Restart it if required:

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

Inspect the service logs:

```bash
journalctl --user -u ydotool.service -b
```

If `ydotool` itself fails, check `/dev/uinput` permissions and the `ydotool` service before troubleshooting the Plasma widget.

### Countdown does not reset when you use the computer

Confirm the idle helper exists:

```bash
ls -l ~/.local/libexec/movemouse/movemouse-idle-monitor
```

Then run both activity tests described above.

If the helper is missing, rerun:

```bash
sudo pacman -S --needed kidletime cmake extra-cmake-modules gcc
bash linux/plasma6/install-cachyos.sh
```

### Widget still looks like an older version

Restart Plasma Shell:

```bash
systemctl --user restart plasma-plasmashell.service
```

If necessary:

1. Remove Move Mouse from the panel/desktop.
2. Run the installer again.
3. Restart Plasma Shell.
4. Add Move Mouse again through **Add Widgets…**.

### Widget cannot be found

Check whether Plasma knows about the package:

```bash
kpackagetool6 --type Plasma/Applet --show org.movemouse.plasma
```

Then rerun:

```bash
bash linux/plasma6/install-cachyos.sh
```

## Uninstall the KDE Plasma edition

Remove the Plasma widget package:

```bash
kpackagetool6 --type Plasma/Applet --remove org.movemouse.plasma
```

Remove the activity helper:

```bash
rm -f ~/.local/libexec/movemouse/movemouse-idle-monitor
```

Optionally disable the `ydotool` service if you do not use it for anything else:

```bash
systemctl --user disable --now ydotool.service
```

You may also remove packages you installed specifically for Move Mouse if you no longer need them. Be careful not to remove KDE dependencies required by other installed software.

## More Linux documentation

See [`linux/plasma6/README.md`](linux/plasma6/README.md) for Linux-specific implementation notes and development details.

---

# Windows

The original Windows application remains available in this repository and is not replaced by the KDE Plasma implementation.

For the original project's Windows installation, scenarios and troubleshooting documentation, see the upstream Move Mouse wiki:

- [Installation](https://github.com/sw3103/movemouse/wiki/installation)
- [Troubleshooting](https://github.com/sw3103/movemouse/wiki/troubleshooting)
- [Scenarios](https://github.com/sw3103/movemouse/wiki/Scenarios)

# Donate

Move Mouse will always be free, but if you would like to buy the original author a beer to show your appreciation, you can do so here:

[PayPal Donate](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QZTWHD9CRW5XN)

# Original project / contact

Original project: [sw3103/movemouse](https://github.com/sw3103/movemouse)

For original Move Mouse suggestions or issues, see the upstream project and its existing contact information.
