# Packet Tracer Installation Script  

This script provides an interactive setup for installing and uninstalling Cisco Packet Tracer without Error on a Linux system.
---
<img width="517" height="385" alt="image" src="https://github.com/user-attachments/assets/34b4b832-459d-42dd-9c54-aec981ab75e4" />

originally download [PacketTracer](https://www.netacad.com/resources/lab-downloads?courseLang=en-US)

## Prerequisites  
- A Debian-based Linux distribution (Ubuntu, Debian, etc.)  
- Internet connection  

## Features  
- Installs Packet Tracer automatically  
- Uninstalls Packet Tracer if needed  
- Uses `xterm` to show download and installation progress  

## Installation and Usage  

### 1. Open Terminal  
Press `Ctrl + Alt + T` to open a terminal window.  

### 2. Download the Script  
```sh
curl -o setup.sh https://raw.githubusercontent.com/andknownmaly/packettracer/refs/heads/main/setup.sh
```

### 3. Navigate to the Script Directory (If Needed)  
If the script is in the `Downloads` folder, navigate there:  
```sh
cd ~/Downloads
```

### 4. Give Execute Permission  
```sh
chmod +x setup.sh
```

### 5. Run the Script  
```sh
./setup.sh
```

### 6. Follow On-Screen Instructions  
- Choose `1` to install Packet Tracer  
- Choose `2` to uninstall Packet Tracer  
- Choose `3` to exit the script  

## Notes  
- The script ensures `xterm` is installed before running the installation.  
- The shortcut for Packet Tracer will be created in `/usr/share/applications/`.  
- If you encounter any issues, try running the script with `sudo`:  
  ```sh
  sudo ./setup.sh
  ```
  or
  ```sh
  sudo bash setup.sh
  ```
