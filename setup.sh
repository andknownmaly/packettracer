#!/bin/bash

sudo apt-get update && sudo apt-get install -y xterm

function install_packettracer() {
    echo "Installing Packet Tracer..."
    cd /tmp || exit
    xterm -hold -e "wget https://github.com/dword32bit/packettracer/releases/download/8.2.2/Packet_Tracer822_amd64_signed.deb"
    xterm -hold -e "sudo dpkg-deb -x ./Packet_Tracer822_amd64_signed.deb /"
    sudo rm -f Packet_Tracer822_amd64_signed.deb
    
    echo "Creating Packet Tracer shortcut..."
    echo -e "[Desktop Entry]\nName=PacketTracer\nExec=/opt/pt/packettracer\nComment=PacketTracer_8.2.2\nTerminal=false\nPrefersNonDefaultGPU=false\nIcon=/opt/pt/art/app.png\nType=Application" > PacketTracer.desktop
    chmod u+x PacketTracer.desktop
    sudo mv PacketTracer.desktop /usr/share/applications/
    echo "Packet Tracer has been successfully installed!"
}

function uninstall_packettracer() {
    echo "Uninstalling Packet Tracer..."
    xterm -hold -e "sudo apt-get remove --purge packettracer -y"
    sudo rm -rf /opt/pt
    sudo rm -f /usr/share/applications/PacketTracer.desktop
    echo "Packet Tracer has been successfully removed!"
}

while true; do
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
