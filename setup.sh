#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

reset_colors() {
    echo -en "${NC}"
}

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do not run this script as root or with sudo.${NC}"
    echo -e "${YELLOW}Run it as a normal user: ./setup.sh${NC}"
    exit 1
fi

echo -e "${YELLOW}Detecting system and installing dependencies...${NC}"
if command -v apt-get &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y wget figlet 2>/dev/null || sudo apt-get install -y wget
elif command -v apt &> /dev/null; then
    sudo apt update -qq
    sudo apt install -y wget figlet 2>/dev/null || sudo apt install -y wget
else
    echo -e "${RED}Error: apt/apt-get not found. This script requires a Debian-based distribution.${NC}"
    exit 1
fi

clear

# ============================================================================
# PACKET TRACER 8.2.2 INSTALLATION FUNCTION
# ============================================================================
function install_packettracer_822() {
    echo -e "${YELLOW}Installing Packet Tracer 8.2.2...${NC}"
    cd /tmp || exit

    if [ ! -f "/tmp/Packet_Tracer822_amd64_signed.deb" ]; then
        echo -e "${YELLOW}Downloading Packet Tracer installer (340 MB)...${NC}"
        wget --progress=bar:force https://github.com/andknownmaly/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to download Packet Tracer installer${NC}"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            return 1
        fi
    else
        echo -e "${GREEN}Using cached Packet Tracer installer...${NC}"
    fi

    echo -e "${YELLOW}Downloading required libraries...${NC}"
    if [ ! -f "/tmp/packettracer-libs.tar.gz" ]; then
        wget --progress=bar:force -O /tmp/packettracer-libs.tar.gz https://github.com/andknownmaly/packettracer/releases/download/lib.1.0/packettracer-libs.tar.gz
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to download libraries${NC}"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            return 1
        fi
    else
        echo -e "${GREEN}Using cached libraries...${NC}"
    fi

    echo -e "${YELLOW}Extracting Packet Tracer to /opt/pt...${NC}"
    sudo dpkg-deb -x ./Packet_Tracer822_amd64_signed.deb / 2>&1 | grep -v "tar:" || true
    
    if [ ! -d "/opt/pt" ]; then
        echo -e "${RED}Error: Failed to extract Packet Tracer${NC}"
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        return 1
    fi

    echo -e "${YELLOW}Installing all required libraries to /opt/pt/lib...${NC}"
    sudo tar -xzf /tmp/packettracer-libs.tar.gz -C /opt/pt/
    
    if [ ! -d "/opt/pt/lib" ]; then
        echo -e "${RED}Error: Failed to extract libraries${NC}"
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        return 1
    fi

    echo -e "${YELLOW}Setting up file associations and MIME types...${NC}"
    sudo mkdir -p /usr/share/mime/packages
    sudo tee /usr/share/mime/packages/cisco-pt.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-pkt">
    <comment>Packet Tracer Network</comment>
    <glob pattern="*.pkt"/>
  </mime-type>
  <mime-type type="application/x-pka">
    <comment>Packet Tracer Activity</comment>
    <glob pattern="*.pka"/>
  </mime-type>
  <mime-type type="application/x-pkz">
    <comment>Packet Tracer Activity Package</comment>
    <glob pattern="*.pkz"/>
  </mime-type>
  <mime-type type="application/x-pks">
    <comment>Packet Tracer Skills</comment>
    <glob pattern="*.pks"/>
  </mime-type>
  <mime-type type="application/x-pksz">
    <comment>Packet Tracer Skills Package</comment>
    <glob pattern="*.pksz"/>
  </mime-type>
</mime-info>
EOF

    if command -v update-mime-database &> /dev/null; then
        sudo update-mime-database /usr/share/mime 2>/dev/null
    fi

    echo -e "${YELLOW}Creating launcher script...${NC}"
    sudo tee /opt/pt/packettracer > /dev/null << 'EOF'
#!/bin/bash

echo Starting Packet Tracer 8.2.2

PTDIR=/opt/pt
export LD_LIBRARY_PATH=/opt/pt/lib:/opt/pt/bin:$LD_LIBRARY_PATH
export PT8HOME=/opt/pt
pushd /opt/pt/bin > /dev/null 2>&1
./PacketTracer "$@" > /dev/null 2>&1
popd > /dev/null 2>&1
EOF
    sudo chmod +x /opt/pt/packettracer

    sudo ln -sf /opt/pt/packettracer /usr/local/bin/packettracer 2>/dev/null

    echo -e "${YELLOW}Updating desktop entries...${NC}"
    sudo tee /usr/share/applications/cisco-pt.desktop > /dev/null << 'EOF'
[Desktop Entry]
Type=Application
Exec=/opt/pt/packettracer %f
Name=Cisco Packet Tracer 8.2.2
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
Categories=Network;Education;Application;
StartupWMClass=PacketTracer
EOF

    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null
    fi
    
    if command -v update-mime-database &> /dev/null; then
        sudo update-mime-database /usr/share/mime 2>/dev/null
    fi
    
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Packet Tracer has been successfully installed!   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}You can run Packet Tracer by:${NC}"
    echo -e "  ${YELLOW}1.${NC} Typing 'packettracer' in terminal"
    echo -e "  ${YELLOW}2.${NC} Finding 'Cisco Packet Tracer' in your application menu"
    echo -e "  ${YELLOW}3.${NC} Running '/opt/pt/packettracer'"
    echo ""
    reset_colors
}

# ============================================================================
# PACKET TRACER 9.0.0 INSTALLATION FUNCTION
# ============================================================================
function install_packettracer_900() {
    echo -e "${YELLOW}Installing Packet Tracer 9.0.0...${NC}"
    cd /tmp || exit

    if [ ! -f "/tmp/CiscoPacketTracer_900_Ubuntu_64bit.deb" ]; then
        echo -e "${YELLOW}Downloading Packet Tracer installer...${NC}"
        wget --progress=bar:force https://github.com/andknownmaly/packettracer/releases/download/9.0.0/CiscoPacketTracer_900_Ubuntu_64bit.deb
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to download Packet Tracer installer${NC}"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            return 1
        fi
    else
        echo -e "${GREEN}Using cached Packet Tracer installer...${NC}"
    fi

    echo -e "${YELLOW}Extracting Packet Tracer to /opt/pt...${NC}"
    sudo dpkg-deb -x ./CiscoPacketTracer_900_Ubuntu_64bit.deb / 2>&1 | grep -v "tar:" || true
    
    if [ ! -d "/opt/pt" ]; then
        echo -e "${RED}Error: Failed to extract Packet Tracer${NC}"
        echo -e "${YELLOW}Press Enter to continue...${NC}"
        read -r
        return 1
    fi

    if [ -f "/opt/pt/packettracer.AppImage" ]; then
        echo -e "${GREEN}Detected AppImage format (Packet Tracer 9.0.0)${NC}"
        echo -e "${CYAN}AppImage is self-contained - No library isolation needed${NC}"
        
        echo -e "${YELLOW}Making AppImage executable...${NC}"
        sudo chmod +x /opt/pt/packettracer.AppImage
        
        echo -e "${YELLOW}Creating symlink to /usr/local/bin...${NC}"
        sudo ln -sf /opt/pt/packettracer.AppImage /usr/local/bin/packettracer 2>/dev/null
        
        echo -e "${YELLOW}Installing desktop launchers...${NC}"
        cd /tmp
        /opt/pt/packettracer.AppImage --appimage-extract "*.desktop" >/dev/null 2>&1
        /opt/pt/packettracer.AppImage --appimage-extract "app.png" >/dev/null 2>&1

        mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
        if [ -f "/tmp/squashfs-root/app.png" ]; then
            cp /tmp/squashfs-root/app.png "$HOME/.local/share/icons/hicolor/256x256/apps/packettracer.png"
        fi
        
        if [ -f "/tmp/squashfs-root/CiscoPacketTracer-9.0.0.desktop" ]; then
            sed -e "s|@EXEC_PATH@|/opt/pt/packettracer.AppImage|g" \
                -e "s|Icon=app|Icon=packettracer|g" \
                /tmp/squashfs-root/CiscoPacketTracer-9.0.0.desktop > "$HOME/.local/share/applications/CiscoPacketTracer-9.0.0.desktop"
            chmod +x "$HOME/.local/share/applications/CiscoPacketTracer-9.0.0.desktop"
        fi
        
        if [ -f "/tmp/squashfs-root/CiscoPacketTracerPtsa-9.0.0.desktop" ]; then
            sed -e "s|@EXEC_PATH@|/opt/pt/packettracer.AppImage|g" \
                -e "s|Icon=app|Icon=packettracer|g" \
                /tmp/squashfs-root/CiscoPacketTracerPtsa-9.0.0.desktop > "$HOME/.local/share/applications/CiscoPacketTracerPtsa-9.0.0.desktop"
            chmod +x "$HOME/.local/share/applications/CiscoPacketTracerPtsa-9.0.0.desktop"
        fi

        rm -rf /tmp/squashfs-root
        
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
        fi
        
        if command -v gtk-update-icon-cache &> /dev/null; then
            gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
        fi

        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║        EULA ACCEPTANCE REQUIRED - FIRST RUN       ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Packet Tracer will now start for EULA acceptance.${NC}"
        echo ""
        echo -e "${CYAN}Instructions:${NC}"
        echo -e "  ${BOLD}1.${NC} Press ${YELLOW}'q'${NC} to quit the EULA viewer"
        echo -e "  ${BOLD}2.${NC} Enter ${YELLOW}'2'${NC} to ${GREEN}accept${NC} the EULA"
        echo -e "  ${BOLD}3.${NC} Close Packet Tracer after it opens"
        echo ""
        read -p "Press Enter to continue..."
        
        /opt/pt/packettracer.AppImage 2>/dev/null
        EULA_STATUS=$?
        
        clear
        echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  Packet Tracer has been successfully installed!   ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}You can run Packet Tracer by:${NC}"
        echo -e "  ${YELLOW}1.${NC} Typing 'packettracer' in terminal"
        echo -e "  ${YELLOW}2.${NC} Finding 'Cisco Packet Tracer 9.0.0' in your application menu"
        echo ""
        return 0
        
    else
        echo -e "${YELLOW}Downloading required libraries...${NC}"
        if [ ! -f "/tmp/packettracer-libs.tar.gz" ]; then
            wget --progress=bar:force -O /tmp/packettracer-libs.tar.gz https://github.com/andknownmaly/packettracer/releases/download/lib.1.0/packettracer-libs.tar.gz
            
            if [ $? -ne 0 ]; then
                echo -e "${YELLOW}Warning: Failed to download libraries, continuing without additional libraries...${NC}"
            fi
        else
            echo -e "${GREEN}Using cached libraries...${NC}"
        fi

        if [ -f "/tmp/packettracer-libs.tar.gz" ]; then
            echo -e "${YELLOW}Installing libraries to /opt/pt/lib/ (isolated)...${NC}"
            sudo tar -xzf /tmp/packettracer-libs.tar.gz -C /opt/pt/ 2>&1
            
            if [ $? -ne 0 ]; then
                echo -e "${YELLOW}Warning: Failed to extract libraries (possibly corrupted cache)${NC}"
                echo -e "${YELLOW}Removing cached file and trying fresh download...${NC}"
                rm -f /tmp/packettracer-libs.tar.gz
                
                wget --progress=bar:force -O /tmp/packettracer-libs.tar.gz https://github.com/andknownmaly/packettracer/releases/download/lib.1.0/packettracer-libs.tar.gz
                
                if [ $? -eq 0 ]; then
                    sudo tar -xzf /tmp/packettracer-libs.tar.gz -C /opt/pt/ 2>&1
                    if [ $? -ne 0 ]; then
                        echo -e "${YELLOW}Warning: Still failed to extract, continuing without additional libraries...${NC}"
                        echo -e "${YELLOW}Packet Tracer 9.0.0 may work without additional libraries.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Warning: Download failed, continuing without additional libraries...${NC}"
                fi
            fi
        fi

        echo -e "${YELLOW}Creating launcher script (with isolated library path)...${NC}"

        if [ -d "/opt/pt/lib" ]; then
            sudo tee /opt/pt/packettracer > /dev/null << 'EOF'
#!/bin/bash

echo Starting Packet Tracer 9.0.0

# Set library path ONLY for this process (isolated, per-process scope)
# Does NOT affect system or other applications
PTDIR=/opt/pt
export LD_LIBRARY_PATH=/opt/pt/lib:/opt/pt/bin:$LD_LIBRARY_PATH
export PT8HOME=/opt/pt
pushd /opt/pt/bin > /dev/null 2>&1
./PacketTracer "$@" > /dev/null 2>&1
popd > /dev/null 2>&1
EOF
        else
            sudo tee /opt/pt/packettracer > /dev/null << 'EOF'
#!/bin/bash

echo Starting Packet Tracer 9.0.0

# Set library path ONLY for this process (isolated, per-process scope)
# Does NOT affect system or other applications
PTDIR=/opt/pt
export LD_LIBRARY_PATH=/opt/pt/bin:$LD_LIBRARY_PATH
export PT8HOME=/opt/pt
pushd /opt/pt/bin > /dev/null 2>&1
./PacketTracer "$@" > /dev/null 2>&1
popd > /dev/null 2>&1
EOF
        fi
        sudo chmod +x /opt/pt/packettracer
        
        sudo ln -sf /opt/pt/packettracer /usr/local/bin/packettracer 2>/dev/null

        echo -e "${YELLOW}Creating application shortcut...${NC}"
        cat > /tmp/PacketTracer.desktop << 'EOF'
[Desktop Entry]
Name=Cisco Packet Tracer
Exec=/opt/pt/packettracer
Comment=Cisco Packet Tracer 9.0.0 - Network Simulation Tool
Terminal=false
Type=Application
Icon=/opt/pt/art/app.png
Categories=Network;Education;
StartupWMClass=PacketTracer
EOF
        chmod +x /tmp/PacketTracer.desktop
        sudo mv /tmp/PacketTracer.desktop /usr/share/applications/

        if command -v update-desktop-database &> /dev/null; then
            sudo update-desktop-database /usr/share/applications/ 2>/dev/null
        fi
        
        clear
        echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  Packet Tracer has been successfully installed!   ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}You can run Packet Tracer by:${NC}"
        echo -e "  ${YELLOW}1.${NC} Typing 'packettracer' in terminal"
        echo -e "  ${YELLOW}2.${NC} Finding 'Cisco Packet Tracer' in your application menu"
        echo -e "  ${YELLOW}3.${NC} Running '/opt/pt/packettracer'"
        echo ""
        reset_colors
    fi
}

# ============================================================================
# UNINSTALL FUNCTION
# ============================================================================
function uninstall_packettracer() {
    echo -e "${YELLOW}Uninstalling Packet Tracer...${NC}"

    if [ ! -d "/opt/pt" ]; then
        echo -e "${RED}Packet Tracer is not installed.${NC}"
        sleep 2
        return
    fi

    echo -e "${RED}This will remove Packet Tracer and all its data.${NC}"
    echo -e -n "${YELLOW}Are you sure? (y/N): ${NC}"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstall cancelled.${NC}"
        sleep 2
        return
    fi

    echo -e "${YELLOW}Removing Packet Tracer package...${NC}"
    sudo dpkg -r PacketTracer 2>/dev/null || true
    sudo rm -rf /opt/pt
    sudo rm -f /usr/share/applications/cisco-pt*.desktop
    sudo rm -f /usr/share/applications/PacketTracer.desktop
    sudo rm -f /usr/local/bin/packettracer
    rm -rf ~/.config/PacketTracer
    rm -f "$HOME/.local/share/applications/CiscoPacketTracer"*.desktop
    rm -f "$HOME/.local/share/icons/hicolor/256x256/apps/packettracer.png"

    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null
        update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
    fi
    
    clear
    echo -e "${GREEN}Packet Tracer has been successfully removed!${NC}"
    echo ""
    reset_colors
}

# ============================================================================
# MAIN MENU
# ============================================================================
while true; do
    clear

    if command -v figlet &> /dev/null; then
        echo -e "${CYAN}${BOLD}"
        figlet -f standard "Packet Tracer" 2>/dev/null || echo "PACKET TRACER INSTALLER"
        echo -e "${NC}"
    else
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════╗"
        echo "║         CISCO PACKET TRACER INSTALLER             ║"
        echo "╚════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi

    if [ -d "/opt/pt" ]; then
        echo -e "${GREEN}Status: Packet Tracer is installed${NC}"
        
        if [ -f "/opt/pt/packettracer.AppImage" ]; then
            echo -e "${CYAN}Version: 9.0.0 (AppImage)${NC}"
        elif [ -f "/opt/pt/packettracer" ]; then
            echo -e "${CYAN}Version: 8.2.2${NC}"
        else
            echo -e "${CYAN}Version: Unknown${NC}"
        fi
    else
        echo -e "${YELLOW}Status: Packet Tracer is not installed${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}1.${NC} Install Packet Tracer 8.2.2"
    echo -e "${BOLD}2.${NC} Install Packet Tracer 9.0.0"
    echo -e "${BOLD}3.${NC} Uninstall Packet Tracer"
    echo -e "${BOLD}4.${NC} Exit"
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
    echo -e -n "${CYAN}Choose an option (1-4): ${NC}"
    read -r choice

    case $choice in
        1)
            install_packettracer_822
            echo ""
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        2)
            install_packettracer_900
            echo ""
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        3)
            uninstall_packettracer
            echo ""
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        4)
            clear
            echo -e "${GREEN}Thank you for using Packet Tracer Installer!${NC}"
            reset_colors
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1-4.${NC}"
            sleep 2
            ;;
    esac
done
