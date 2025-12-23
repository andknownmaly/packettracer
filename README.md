# 🧠 Cisco Packet Tracer Installer for Linux

[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Based On](https://img.shields.io/badge/based%20on-Debian%2FUbuntu-orange.svg)](https://ubuntu.com/)
[![PacketTracer](https://img.shields.io/badge/Cisco-PacketTracer-red.svg)](https://www.netacad.com/resources/lab-downloads?courseLang=en-US)

An **interactive installation and uninstallation script** for **Cisco Packet Tracer** on **Linux-based systems**, especially **APT-based distros** like Ubuntu, Debian, and Kali Linux.
Designed to eliminate common installation errors and streamline setup for NetAcad users.

---

<img width="537" height="263" alt="image" src="https://github.com/user-attachments/assets/89aa918b-1c10-4f03-9c60-66e154e3a2a7" />


Originally, Packet Tracer can be downloaded from [Cisco NetAcad](https://www.netacad.com/resources/lab-downloads?courseLang=en-US).

---

## ⚙️ Features

* ✅ Automatic Packet Tracer installation
* 🧹 Clean uninstallation option
* 📦 Uses `xterm` to show download and installation progress
* 🪄 Auto-checks dependencies for smooth setup
* 🧰 Compatible with Debian, Ubuntu, Kali, and other APT-based distros

---

## 🧩 Prerequisites

* Debian-based Linux distribution (Ubuntu, Debian, Kali, etc.)
* Active Internet connection

---

## 🚀 Installation & Usage

### 1️⃣ Open Terminal

Press `Ctrl + Alt + T` to open a terminal.

### 2️⃣ Download the Script

```bash
curl -o setup.sh https://raw.githubusercontent.com/andknownmaly/packettracer/refs/heads/main/setup.sh
```

### 3️⃣ Navigate to Script Directory (if needed)

```bash
cd ~/Downloads
```

### 4️⃣ Give Execute Permission

```bash
chmod +x setup.sh
```

### 5️⃣ Run the Script

```bash
./setup.sh
```

### 6️⃣ Follow the On-Screen Menu

* `1` → Install Packet Tracer
* `2` → Uninstall Packet Tracer
* `3` → Exit

---

## 📝 Notes

* The script ensures `xterm` is installed before continuing.
* A desktop shortcut is created in:

  ```
  /usr/share/applications/
  ```
* If you face permission issues, try running with `sudo`:

  ```bash
  sudo ./setup.sh
  ```

  or

  ```bash
  sudo bash setup.sh
  ```

---

## 🪪 License

This project is distributed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Pull requests are welcome!
If you have improvements, feature ideas, or distro-specific fixes, feel free to contribute.
