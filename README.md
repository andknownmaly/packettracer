# Cisco Packet Tracer Installer for Linux

[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Based On](https://img.shields.io/badge/based%20on-Debian%2FUbuntu-orange.svg)](https://ubuntu.com/)
[![PacketTracer](https://img.shields.io/badge/Cisco-PacketTracer-red.svg)](https://www.netacad.com/resources/lab-downloads?courseLang=en-US)

An **interactive installation and uninstallation script** for **Cisco Packet Tracer** on **Linux-based systems**, especially **APT-based distros** like Ubuntu, Debian, and Kali Linux.
Designed to eliminate common installation errors and streamline setup for NetAcad users.

**Now supports both Packet Tracer 8.2.2 and 9.0.0!**

---

<img width="537" height="263" alt="image" src="https://github.com/user-attachments/assets/89aa918b-1c10-4f03-9c60-66e154e3a2a7" /><img width="504" height="256" alt="image" src="https://github.com/user-attachments/assets/35c0b735-5538-460a-bd2f-740e3945215f" />



Originally packet, this Packet Tracer is downloaded from [Cisco NetAcad](https://www.netacad.com/resources/lab-downloads?courseLang=en-US).

---

## ⚙️ Features

* ✅ Automatic Packet Tracer installation (supports version 8.2.2 and 9.0.0)
* 🧹 Clean uninstallation option
* 📦 Uses `xterm` to show download and installation progress
* 🪄 Auto-checks dependencies for smooth setup
* 🧰 Compatible with Debian, Ubuntu, Kali, and other APT-based distros
* 🎯 AppImage support for Packet Tracer 9.0.0
* 🔧 Automatic EULA handling and desktop launcher creation

---

## 🧩 Prerequisites

* Debian-based Linux distribution (Ubuntu, Debian, Kali, etc.)
* Active Internet connection

---

## 🚀 Installation & Usage

### Version 9.0.0 (Recommended - Latest)

#### 1️ Open Terminal

Press `Ctrl + Alt + T` to open a terminal.

#### 2️ Download the Script

```bash
curl -o setup.sh https://raw.githubusercontent.com/andknownmaly/packettracer/refs/heads/main/setup_9.0.0.sh
```

#### 3️ Give Execute Permission

```bash
chmod +x setup.sh
```

#### 4️ Run the Script

```bash
./setup.sh
```

#### 5️ Follow the On-Screen Menu

* `1` → Install Packet Tracer 9.0.0
* `2` → Uninstall Packet Tracer
* `3` → Exit

---

### Version 8.2.2 (Legacy)

#### 1️ Open Terminal

Press `Ctrl + Alt + T` to open a terminal.

#### 2️ Download the Script

```bash
curl -o setup.sh https://raw.githubusercontent.com/andknownmaly/packettracer/refs/heads/main/setup_8.2.2.sh
```

#### 3️ Give Execute Permission

```bash
chmod +x setup.sh
```

#### 4️ Run the Script

```bash
./setup.sh
```

#### 5️ Follow the On-Screen Menu

* `1` → Install Packet Tracer 8.2.2
* `2` → Uninstall Packet Tracer
* `3` → Exit

---

## 📝 Notes

### General
* The script ensures `xterm` is installed before continuing.
* If you face permission issues, **do not** run with `sudo`. The script will ask for sudo password when needed.

### Version 9.0.0 Specific
* Uses AppImage format for easier installation
* Desktop launchers are automatically created in `~/.local/share/applications/`
* EULA acceptance is required on first run
* Icons are properly installed to avoid conflicts with other applications
* Launchers created:
  - **Cisco Packet Tracer 9.0.0** - Main application
  - **Cisco Packet Tracer 9.0.0 (PTSA)** - Protocol handler

### Version 8.2.2 Specific
* Traditional installation with library dependencies
* Desktop shortcut is created in `/usr/share/applications/`
* Requires additional system libraries (automatically downloaded)

---

## 🗂️ Installation Locations

### Version 9.0.0
* Application: `/opt/pt/packettracer.AppImage`
* Symlink: `/usr/local/bin/packettracer`
* Launchers: `~/.local/share/applications/CiscoPacketTracer*.desktop`
* Icon: `~/.local/share/icons/hicolor/256x256/apps/packettracer.png`
* Config: `~/.config/Packet Tracer/`

### Version 8.2.2
* Application: `/opt/pt/`
* Libraries: `/opt/pt/lib/`
* Launcher: `/opt/pt/packettracer`
* Symlink: `/usr/local/bin/packettracer`
* Desktop: `/usr/share/applications/PacketTracer.desktop`
* Config: `~/.config/PacketTracer/`

---

## 🪪 License

This project is distributed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Pull requests are welcome!
If you have improvements, feature ideas, or distro-specific fixes, feel free to contribute.
