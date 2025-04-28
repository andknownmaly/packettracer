#!/bin/bash

sudo apt-get update && sudo apt-get install -y xterm
clear
function install_packettracer() {
    echo "Installing Packet Tracer..."
    cd /tmp || exit
    xterm -e "wget https://github.com/andknownmaly/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb"
    xterm -e "sudo dpkg-deb -x ./Packet_Tracer822_amd64_signed.deb /"
    sudo rm -f Packet_Tracer822_amd64_signed.deb
    
    echo "Creating Packet Tracer shortcut..."
    echo -e "[Desktop Entry]\nName=PacketTracer\nExec=/opt/pt/packettracer\nComment=PacketTracer_8.2.2\nTerminal=false\nPrefersNonDefaultGPU=false\nIcon=/opt/pt/art/app.png\nType=Application" > PacketTracer.desktop
    chmod u+x PacketTracer.desktop
    sudo mv PacketTracer.desktop /usr/share/applications/
    clear
    echo "Packet Tracer has been successfully installed!"
}

function uninstall_packettracer() {
    echo "Uninstalling Packet Tracer..."
    sudo rm -rf /opt/pt
    sudo rm -f /usr/share/applications/PacketTracer.desktop
    clear
    echo "Packet Tracer has been successfully removed!"
}

while true; do
    figlet "Packet Tracer Installer"
    echo "========================="
    echo "  Packet Tracer Setup  "
    echo "========================="
    echo "1. Install Packet Tracer"
    echo "2. Uninstall Packet Tracer"
    echo "3. Exit"
    echo -n "Choose an option (1-3): "
    read choice

    case $choice in
        1)
            install_packettracer
            ;;
        2)
            uninstall_packettracer
            ;;
        3)
            echo "Exiting setup."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
    echo ""
done
