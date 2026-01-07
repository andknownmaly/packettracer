# Cisco Packet Tracer Installer for Linux

[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Based On](https://img.shields.io/badge/based%20on-Debian%2FUbuntu-orange.svg)](https://ubuntu.com/)
[![PacketTracer](https://img.shields.io/badge/Cisco-PacketTracer-red.svg)](https://www.netacad.com/resources/lab-downloads?courseLang=en-US)

An **interactive unified installation script** for **Cisco Packet Tracer** on **Linux-based systems**, especially **APT-based distros** like Ubuntu, Debian, and Kali Linux.
Designed to eliminate common installation errors and streamline setup for NetAcad users.

**Single script supporting both Packet Tracer 8.2.2 and 9.0.0!**

---




Originally packet, this Packet Tracer is downloaded from [Cisco NetAcad](https://www.netacad.com/resources/lab-downloads?courseLang=en-US).

---

## ⚙️ Features

* ✅ **Unified script** for both Packet Tracer 8.2.2 and 9.0.0
* 🎯 Interactive menu to choose version
* 🧹 Clean uninstallation option
* 📦 Uses `xterm` to show download and installation progress
* 🪄 Auto-checks dependencies for smooth setup
* 🧰 Compatible with Debian, Ubuntu, Kali, and other APT-based distros
* 🎯 AppImage support for Packet Tracer 9.0.0
* 🔧 Automatic EULA handling and desktop launcher creation
* 🔄 Easy version switching

---

## 🧩 Prerequisites

* Debian-based Linux distribution (Ubuntu, Debian, Kali, etc.)
* Active Internet connection

---

## 🚀 Installation & Usage

### Quick Start (Unified Script)

#### 1️⃣ Open Terminal

Press `Ctrl + Alt + T` to open a terminal.

#### 2️⃣ Download the Script

```bash
curl -o setup.sh https://raw.githubusercontent.com/andknownmaly/packettracer/refs/heads/main/setup.sh
```

#### 3️⃣ Give Execute Permission

```bash
chmod +x setup.sh
```

#### 4️⃣ Run the Script

```bash
./setup.sh
```

#### 5️⃣ Follow the Interactive Menu

The script will display:
* **Option 1** → Install Packet Tracer 8.2.2
* **Option 2** → Install Packet Tracer 9.0.0 (Recommended)
* **Option 3** → Uninstall Packet Tracer
* **Option 4** → Exit

---

## ⚠️ Important Notes for Version 8.2.2

### Login Issue Workaround

**Version 8.2.2 uses isolated libraries** and may experience login problems due to library isolation. If you need to use version 8.2.2:

#### Recommended Workaround:
1. **First install version 9.0.0** using the script (Option 2)
2. Login to your Cisco NetAcad account in version 9.0.0
3. Uninstall version 9.0.0 (Option 3)
4. Install version 8.2.2 (Option 1)

This workaround allows 8.2.2 to inherit the authentication from 9.0.0, bypassing the isolated library login issue.

**Alternative:** If you don't need login functionality, version 8.2.2 works fine for local projects and offline usage.

---

## 📝 Additional Notes

### General
* The script ensures `xterm` is installed before continuing.
* If you face permission issues, **do not** run with `sudo`. The script will ask for sudo password when needed.
* The unified script automatically detects if Packet Tracer is already installed and shows version information.

### Version 9.0.0 Specific
* **Recommended version** for most users
* Uses AppImage format for easier installation
* Desktop launchers are automatically created in `~/.local/share/applications/`
* EULA acceptance is required on first run
* Icons are properly installed to avoid conflicts with other applications
* Better library compatibility
* Launchers created:
  - **Cisco Packet Tracer 9.0.0** - Main application
  - **Cisco Packet Tracer 9.0.0 (PTSA)** - Protocol handler

### Version 8.2.2 Specific
* **Legacy version** with isolated library system
* Traditional installation with library dependencies
* Desktop shortcut is created in `/usr/share/applications/`
* Requires additional system libraries (automatically downloaded)
* **Known Issue:** Login problems due to isolated libraries (see workaround above)
* Best for offline usage or when specific 8.2.2 features are needed

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
