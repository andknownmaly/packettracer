#!/usr/bin/env bash
set -uo pipefail

REL="https://github.com/andknownmaly/packettracer/releases/download"
DEB_822_URL="$REL/8.2.2/Packet_Tracer822_amd64_signed.deb"
DEB_900_URL="$REL/9.0.0/CiscoPacketTracer_900_Ubuntu_64bit.deb"
LIBS_URL="$REL/lib.1.0/packettracer-libs.tar.gz"

PT_DIR=/opt/pt
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/packettracer-installer"
LOCAL_DEB="${PT_DEB:-}"
APPS="$HOME/.local/share/applications"
ICONS="$HOME/.local/share/icons/hicolor/256x256/apps"
WORK=""
DEB=""

info() { printf '\033[0;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*" >&2; }
err()  { printf '\033[0;31m[x] %s\033[0m\n' "$*" >&2; }
pause() { read -r -p "Press Enter to continue..." _ || true; }
cleanup() { [ -n "$WORK" ] && rm -rf "$WORK"; return 0; }
trap cleanup EXIT

[ "$EUID" -eq 0 ] && { err "Do not run as root or with sudo. Run: ./setup.sh"; exit 1; }
command -v apt-get >/dev/null || { err "apt-get not found: Debian-based distro required."; exit 1; }
[ "$(dpkg --print-architecture)" = "amd64" ] || { err "Packet Tracer for Linux is amd64 only."; exit 1; }
sudo -v || { err "sudo access is required."; exit 1; }
mkdir -p "$CACHE"

apt_try() {
    local p
    for p in "$@"; do
        if sudo apt-get install -y "$p" >/dev/null 2>&1; then info "Installed $p"; return 0; fi
    done
    warn "Could not install any of: $*"
    return 1
}

install_deps() {
    info "Installing dependencies..."
    sudo apt-get update -qq || warn "apt-get update failed, continuing"
    apt_try wget || { err "wget is required."; return 1; }
    apt_try libfuse2t64 libfuse2
    apt_try libpcre2-32-0
    apt_try libpcre2-posix3
    return 0
}

fetch() {
    local url=$1 dest=$2
    [ -s "$dest" ] && { info "Using cached $(basename "$dest")"; return 0; }
    info "Downloading $(basename "$dest")..."
    if wget --progress=bar:force -O "$dest.part" "$url"; then
        mv "$dest.part" "$dest"
    else
        rm -f "$dest.part"; err "Download failed: $url"; return 1
    fi
}

get_deb() {
    if [ -n "$LOCAL_DEB" ]; then
        [ -f "$LOCAL_DEB" ] || { err "PT_DEB not found: $LOCAL_DEB"; return 1; }
        DEB=$LOCAL_DEB
    else
        DEB="$CACHE/$(basename "$1")"
        fetch "$1" "$DEB" || return 1
    fi
    if ! dpkg-deb --info "$DEB" >/dev/null 2>&1; then
        err "$DEB is not a valid .deb"
        [ -z "$LOCAL_DEB" ] && rm -f "$DEB"
        return 1
    fi
}

fix_perms() {
    sudo chown -R -h root:root "$PT_DIR"
    sudo chmod -R u+rwX,go+rX,go-w "$PT_DIR"
}

deploy() {
    WORK=$(mktemp -d -p "$CACHE") || return 1
    info "Extracting package..."
    dpkg-deb -x "$DEB" "$WORK" || { err "Extraction failed."; return 1; }
    [ -d "$WORK/opt/pt" ] || { err "Package does not contain opt/pt."; return 1; }
    info "Installing to $PT_DIR..."
    sudo rm -rf "$PT_DIR"
    sudo mkdir -p /opt
    sudo cp -a --no-preserve=ownership "$WORK/opt/pt" "$PT_DIR" || { err "Copy failed."; return 1; }
    fix_perms
    rm -rf "$WORK"; WORK=""
}

refresh_dbs() {
    command -v update-mime-database >/dev/null && sudo update-mime-database /usr/share/mime 2>/dev/null
    command -v update-desktop-database >/dev/null && {
        sudo update-desktop-database /usr/share/applications 2>/dev/null
        [ -d "$APPS" ] && update-desktop-database "$APPS" 2>/dev/null
    }
    return 0
}

install_822() {
    install_deps || return 1
    get_deb "$DEB_822_URL" || return 1
    local libs="$CACHE/packettracer-libs.tar.gz"
    fetch "$LIBS_URL" "$libs" || return 1
    tar -tzf "$libs" >/dev/null 2>&1 || { rm -f "$libs"; err "Library archive is corrupt, re-run to download again."; return 1; }

    deploy || return 1

    info "Installing bundled libraries to $PT_DIR/lib..."
    sudo tar -xzf "$libs" -C "$PT_DIR" --no-same-owner || { err "Library extraction failed."; return 1; }
    fix_perms
    [ -d "$PT_DIR/lib" ] || { err "$PT_DIR/lib missing after extraction."; return 1; }

    info "Registering file types..."
    sudo mkdir -p /usr/share/mime/packages
    sudo tee /usr/share/mime/packages/cisco-pt.xml >/dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-pkt"><comment>Packet Tracer Network</comment><glob pattern="*.pkt"/></mime-type>
  <mime-type type="application/x-pka"><comment>Packet Tracer Activity</comment><glob pattern="*.pka"/></mime-type>
  <mime-type type="application/x-pkz"><comment>Packet Tracer Activity Package</comment><glob pattern="*.pkz"/></mime-type>
  <mime-type type="application/x-pks"><comment>Packet Tracer Skills</comment><glob pattern="*.pks"/></mime-type>
  <mime-type type="application/x-pksz"><comment>Packet Tracer Skills Package</comment><glob pattern="*.pksz"/></mime-type>
</mime-info>
EOF

    info "Creating launcher..."
    sudo tee "$PT_DIR/packettracer" >/dev/null <<'EOF'
#!/bin/bash
PTDIR=/opt/pt
LOG="${XDG_CACHE_HOME:-$HOME/.cache}/packettracer.log"
mkdir -p "$(dirname "$LOG")"
export LD_LIBRARY_PATH="$PTDIR/lib:$PTDIR/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PT8HOME="$PTDIR"
cd "$PTDIR/bin" || exit 1
exec ./PacketTracer "$@" >"$LOG" 2>&1
EOF
    sudo chmod 755 "$PT_DIR/packettracer"
    sudo ln -sf "$PT_DIR/packettracer" /usr/local/bin/packettracer

    sudo tee /usr/share/applications/cisco-pt.desktop >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Cisco Packet Tracer 8.2.2
Exec=/opt/pt/packettracer %f
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
Categories=Network;Education;
StartupWMClass=PacketTracer
EOF
    refresh_dbs
    info "Packet Tracer 8.2.2 installed. Run 'packettracer' or use the app menu."
    info "If it fails to start, check ~/.cache/packettracer.log"
}

install_900() {
    install_deps || return 1
    get_deb "$DEB_900_URL" || return 1
    deploy || return 1

    local app="$PT_DIR/packettracer.AppImage"
    [ -f "$app" ] || { err "No AppImage found in $PT_DIR; this package layout is not supported."; return 1; }
    sudo chmod 755 "$app"
    sudo ln -sf "$app" /usr/local/bin/packettracer

    info "Installing desktop launchers..."
    mkdir -p "$APPS" "$ICONS"
    WORK=$(mktemp -d -p "$CACHE") || return 1
    ( cd "$WORK" && "$app" --appimage-extract '*.desktop' >/dev/null 2>&1
      cd "$WORK" && "$app" --appimage-extract 'app.png'   >/dev/null 2>&1 )
    [ -f "$WORK/squashfs-root/app.png" ] && cp "$WORK/squashfs-root/app.png" "$ICONS/packettracer.png"
    local f
    for f in "$WORK"/squashfs-root/*.desktop; do
        [ -f "$f" ] || continue
        sed -e "s|@EXEC_PATH@|$app|g" -e "s|^Icon=app$|Icon=packettracer|" "$f" > "$APPS/$(basename "$f")"
    done
    rm -rf "$WORK"; WORK=""
    command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
    refresh_dbs

    info "Packet Tracer 9.0.0 installed."
    echo "The first run shows the EULA in this terminal: press 'q' to leave the viewer,"
    echo "then enter '2' to accept. Close Packet Tracer once it opens."
    local a
    read -r -p "Start it now for EULA acceptance? [Y/n] " a || a=n
    if [[ ! "$a" =~ ^[Nn]$ ]]; then
        "$app" || warn "Packet Tracer exited with an error. Try: packettracer --appimage-extract-and-run"
    fi
}

uninstall_pt() {
    local a
    read -r -p "Remove Packet Tracer from this system? [y/N] " a || return
    [[ "$a" =~ ^[Yy]$ ]] || { info "Cancelled."; return; }
    sudo rm -rf "$PT_DIR"
    sudo rm -f /usr/local/bin/packettracer
    sudo rm -f /usr/share/applications/cisco-pt*.desktop /usr/share/applications/PacketTracer.desktop
    sudo rm -f /usr/share/mime/packages/cisco-pt.xml
    rm -f "$APPS"/CiscoPacketTracer*.desktop "$ICONS/packettracer.png"
    refresh_dbs
    read -r -p "Also delete your settings and saved login (~/.config/PacketTracer*)? [y/N] " a || a=n
    if [[ "$a" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.config/PacketTracer" "$HOME/.config/Packet Tracer"
    fi
    info "Packet Tracer removed."
}

repair_ownership() {
    local d dirs=(/ /opt /usr /usr/share /usr/share/applications /usr/share/icons
                  /usr/share/icons/gnome /usr/share/icons/gnome/48x48
                  /usr/share/icons/gnome/48x48/mimetypes /usr/share/mime /usr/share/mime/packages)
    for d in "${dirs[@]}"; do
        [ -d "$d" ] || continue
        if [ "$(stat -c '%U:%G' "$d")" != "root:root" ]; then
            warn "$d is owned by $(stat -c '%U:%G' "$d"), resetting to root:root"
            sudo chown root:root "$d" && sudo chmod 755 "$d"
        fi
    done
    info "Ownership check finished."
}

while true; do
    echo
    echo "=========== Cisco Packet Tracer installer ==========="
    if [ -f "$PT_DIR/packettracer.AppImage" ]; then echo "Status: 9.0.0 installed (AppImage)"
    elif [ -x "$PT_DIR/bin/PacketTracer" ];   then echo "Status: 8.2.2 installed"
    elif [ -d "$PT_DIR" ];                    then echo "Status: incomplete install in $PT_DIR"
    else echo "Status: not installed"; fi
    echo "1) Install Packet Tracer 9.0.0 (recommended)"
    echo "2) Install Packet Tracer 8.2.2"
    echo "3) Uninstall"
    echo "4) Repair system folder ownership (if an older setup.sh changed it)"
    echo "5) Exit"
    read -r -p "Choose (1-5): " choice || exit 0
    case "$choice" in
        1) install_900 || err "Installation of 9.0.0 did not complete."; pause ;;
        2) install_822 || err "Installation of 8.2.2 did not complete."; pause ;;
        3) uninstall_pt; pause ;;
        4) repair_ownership; pause ;;
        5) exit 0 ;;
        *) warn "Invalid choice." ;;
    esac
done
