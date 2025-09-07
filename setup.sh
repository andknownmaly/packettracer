#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

reset_colors() {
    echo -en "${NC}"
}

sudo apt-get update && sudo apt-get install -y xterm
clear

function install_packettracer() {
    echo -e "${YELLOW}Installing Packet Tracer...${NC}"
    cd /tmp || exit

    if [ ! -f "/tmp/Packet_Tracer822_amd64_signed.deb" ]; then
        xterm -e "wget https://github.com/andknownmaly/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb"
    else
        echo -e "${GREEN}Using cached Packet Tracer installer...${NC}"
    fi

    xterm -e "sudo dpkg-deb -x ./Packet_Tracer822_amd64_signed.deb /"
    
    echo -e "${YELLOW}Creating Packet Tracer shortcut...${NC}"
    echo -e "[Desktop Entry]\nName=PacketTracer\nExec=/opt/pt/packettracer\nComment=PacketTracer_8.2.2\nTerminal=false\nPrefersNonDefaultGPU=false\nIcon=/opt/pt/art/app.png\nType=Application" > PacketTracer.desktop
    chmod u+x PacketTracer.desktop
    sudo mv PacketTracer.desktop /usr/share/applications/
    
    clear
    echo -e "${GREEN}Packet Tracer has been successfully installed!${NC}"
    reset_colors
}

function uninstall_packettracer() {
    echo -e "${YELLOW}Uninstalling Packet Tracer...${NC}"
    sudo rm -rf /opt/pt
    sudo rm -f /usr/share/applications/PacketTracer.desktop
    rm -rf ~/.config/PacketTracer
    clear
    echo -e "${GREEN}Packet Tracer has been successfully removed!${NC}"
    reset_colors
}

while true; do
    clear
    echo -e "${CYAN}${BOLD}"
    figlet "Packet Tracer Installer"
    echo -e "${NC}${YELLOW}=========================${NC}"
    echo -e "${CYAN}${BOLD}  Packet Tracer Setup  ${NC}"
    echo -e "${YELLOW}=========================${NC}"
    echo -e "${BOLD}1.${NC} Install Packet Tracer"
    echo -e "${BOLD}2.${NC} Uninstall Packet Tracer"
    echo -e "${BOLD}3.${NC} Exit"
    echo -e -n "${CYAN}Choose an option (1-3): ${NC}"
    read choice

    case $choice in
        1)
            install_packettracer
            ;;
        2)
            uninstall_packettracer
            ;;
        3)
            echo -e "${GREEN}Exiting setup.${NC}"
            reset_colors
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Invalid choice, please try again.${NC}"
            ;;
    esac
    echo ""
done
