# About
Move Mouse is a simple piece of software that is designed to simulate user activity.

Originally designed to prevent Windows from locking the user session or going to sleep, Move Mouse can be deployed in a wide range of [Scenarios](https://github.com/sw3103/movemouse/wiki/Scenarios).

<img src="Images/mm_blue.png" width="200">

# Linux / CachyOS / KDE Plasma 6

This fork now also contains a KDE Plasma 6 widget designed for CachyOS and other Arch-based Linux distributions. The Linux implementation supports Plasma Wayland by using `ydotool`/Linux `uinput` for pointer movement, while leaving the existing Windows/WPF application unchanged.

See [`linux/plasma6/README.md`](linux/plasma6/README.md) for requirements, installation, configuration and troubleshooting.

Quick install after cloning the repository:

```bash
sudo pacman -S ydotool
systemctl --user enable --now ydotool.service
bash linux/plasma6/install-cachyos.sh
```

Then right-click your KDE Plasma panel, choose **Add Widgets…**, search for **Move Mouse**, and add it to the panel.

# Donate
Move Mouse will always be free, but if you would like to buy me a beer to show your appreciation, you can do so using the following link. Thanks!

[PayPal Donate](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QZTWHD9CRW5XN)

# Wiki
Head over to the [Wiki](https://github.com/sw3103/movemouse/wiki) where you will find a bunch of articles for [Installation](https://github.com/sw3103/movemouse/wiki/installation), [Troubleshooting](https://github.com/sw3103/movemouse/wiki/troubleshooting), etc.

# Contact
Please feel free to contact me via [Twitter](https://twitter.com/movemouse) or [email](mailto:contact@movemouse.co.uk) for any suggestions or issues you may have. A lot of the features which are included in Move Mouse today exist because of feedback I have received.
