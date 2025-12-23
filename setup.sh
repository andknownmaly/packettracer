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
    sudo apt-get install -y wget xterm figlet 2>/dev/null || sudo apt-get install -y wget xterm
elif command -v apt &> /dev/null; then
    sudo apt update -qq
    sudo apt install -y wget xterm figlet 2>/dev/null || sudo apt install -y wget xterm
else
    echo -e "${RED}Error: apt/apt-get not found. This script requires a Debian-based distribution.${NC}"
    exit 1
fi

clear

function install_packettracer() {
    echo -e "${YELLOW}Installing Packet Tracer 8.2.2...${NC}"
    cd /tmp || exit

    if [ ! -f "/tmp/Packet_Tracer822_amd64_signed.deb" ]; then
        echo -e "${YELLOW}Downloading Packet Tracer installer (340 MB)...${NC}"
        if command -v xterm &> /dev/null; then
            xterm -e "wget https://github.com/andknownmaly/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb"
        else
            wget --progress=bar:force https://github.com/andknownmaly/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb
        fi
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to download Packet Tracer installer${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Using cached Packet Tracer installer...${NC}"
    fi

    echo -e "${YELLOW}Extracting Packet Tracer to /opt/pt...${NC}"
    sudo dpkg-deb -x ./Packet_Tracer822_amd64_signed.deb / 2>&1 | grep -v "tar:"
    
    if [ ! -d "/opt/pt" ]; then
        echo -e "${RED}Error: Failed to extract Packet Tracer${NC}"
        return 1
    fi

    echo -e "${YELLOW}Downloading required libraries (28 MB)...${NC}"
    if [ ! -f "/tmp/packettracer-libs.tar.gz" ]; then
        wget --progress=bar:force -O /tmp/packettracer-libs.tar.gz https://github.com/andknownmaly/packettracer/releases/download/8.2.2/packettracer-libs.tar.gz
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to download libraries${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Using cached libraries...${NC}"
    fi

    echo -e "${YELLOW}Installing libraries to /opt/pt/lib...${NC}"
    sudo tar -xzf /tmp/packettracer-libs.tar.gz -C /opt/pt/
    
    if [ ! -d "/opt/pt/lib" ]; then
        echo -e "${RED}Error: Failed to extract libraries${NC}"
        return 1
    fi

    echo -e "${YELLOW}Creating launcher script...${NC}"
    sudo tee /opt/pt/packettracer > /dev/null << 'EOF'
#!/bin/bash

echo Starting Packet Tracer 8.2.2

PTDIR=/opt/pt
export LD_LIBRARY_PATH=/opt/pt/lib:/opt/pt/bin:$LD_LIBRARY_PATH
pushd /opt/pt/bin > /dev/null 2>&1
./PacketTracer "$@" > /dev/null 2>&1
popd > /dev/null 2>&1
EOF
    sudo chmod +x /opt/pt/packettracer

    sudo ln -sf /opt/pt/packettracer /usr/local/bin/packettracer 2>/dev/null

    echo -e "${YELLOW}Creating application shortcut...${NC}"
    cat > /tmp/PacketTracer.desktop << 'EOF'
[Desktop Entry]
Name=Cisco Packet Tracer
Exec=/opt/pt/packettracer
Comment=Cisco Packet Tracer 8.2.2 - Network Simulation Tool
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
}

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

    sudo rm -rf /opt/pt
    sudo rm -f /usr/share/applications/PacketTracer.desktop
    sudo rm -f /usr/local/bin/packettracer
    rm -rf ~/.config/PacketTracer

    if command -v update-desktop-database &> /dev/null; then
        sudo update-desktop-database /usr/share/applications/ 2>/dev/null
    fi
    
    clear
    echo -e "${GREEN}Packet Tracer has been successfully removed!${NC}"
    echo ""
    reset_colors
}

while true; do
    clear

    if command -v figlet &> /dev/null; then
        echo -e "${CYAN}${BOLD}"
        figlet -f standard "Packet Tracer" 2>/dev/null || echo "PACKET TRACER INSTALLER"
        echo -e "${NC}"
    else
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════╗"
        echo "║         CISCO PACKET TRACER INSTALLER 8.2.2       ║"
        echo "╚════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi

    if [ -d "/opt/pt" ]; then
        echo -e "${GREEN}Status: Packet Tracer is installed${NC}"
    else
        echo -e "${YELLOW}Status: Packet Tracer is not installed${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}1.${NC} Install Packet Tracer 8.2.2"
    echo -e "${BOLD}2.${NC} Uninstall Packet Tracer"
    echo -e "${BOLD}3.${NC} Exit"
    echo -e "${YELLOW}═══════════════════════════════════════════════════${NC}"
    echo -e -n "${CYAN}Choose an option (1-3): ${NC}"
    read -r choice

    case $choice in
        1)
            install_packettracer
            echo ""
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        2)
            uninstall_packettracer
            echo ""
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        3)
            clear
            echo -e "${GREEN}Thank you for using Packet Tracer Installer!${NC}"
            reset_colors
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1-3.${NC}"
            sleep 2
            ;;
    esac
done
