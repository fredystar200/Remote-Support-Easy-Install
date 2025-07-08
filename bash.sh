#!/bin/bash

set -e

main_menu() {
    clear
    echo "=================================================="
    echo "  Remote Support Install (by fredystar200)"
    echo "=================================================="
    echo "1. Install AnyDesk"
    echo "2. Install RustDesk"
    echo "3. Uninstall AnyDesk and RustDesk"
    echo "=================================================="
    read -p "Select an option (1/2/3): " choice
    case "$choice" in
        1) install_anydesk ;;
        2) install_rustdesk ;;
        3) uninstall_all ;;
        *) main_menu ;;
    esac
}

detect_os() {
    UNAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$UNAME" in
        linux*)    PLATFORM="linux" ;;
        darwin*)   PLATFORM="mac" ;;
        *)         echo "Unsupported OS: $UNAME"; exit 1 ;;
    esac
}

install_anydesk() {
    detect_os
    if [ "$PLATFORM" = "linux" ]; then
        echo "Installing AnyDesk (Linux)..."
        sudo apt-get update
        sudo apt-get install -y wget gnupg lsb-release apt-transport-https
        wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /usr/share/keyrings/anydesk-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list >/dev/null
        sudo apt-get update
        sudo apt-get install -y anydesk
        echo "Launching AnyDesk..."
        nohup anydesk >/dev/null 2>&1 &
    elif [ "$PLATFORM" = "mac" ]; then
        echo "Installing AnyDesk (Mac)..."
        TMPDMG=$(mktemp /tmp/anydesk_XXXX.dmg)
        curl -L "https://download.anydesk.com/macos/anydesk.dmg" -o "$TMPDMG"
        hdiutil attach "$TMPDMG" -nobrowse
        cp -R "/Volumes/AnyDesk/AnyDesk.app" /Applications/
        hdiutil detach "/Volumes/AnyDesk"
        rm -f "$TMPDMG"
        echo "Launching AnyDesk..."
        open -a AnyDesk
    fi
    echo
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

install_rustdesk() {
    detect_os
    if [ "$PLATFORM" = "linux" ]; then
        echo "Installing RustDesk (Linux)..."
        # Try to get the latest .deb (amd64/x86_64)
        RUST_URL=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep browser_download_url | grep -i ".deb" | grep -i "amd64\|x86_64" | cut -d '"' -f4 | head -n 1)
        if [ -n "$RUST_URL" ]; then
            echo "Downloading: $RUST_URL"
            TMPDEB=$(mktemp /tmp/rustdesk_XXXX.deb)
            curl -L "$RUST_URL" -o "$TMPDEB"
            sudo dpkg -i "$TMPDEB" || sudo apt-get install -f -y
            rm -f "$TMPDEB"
            echo "Launching RustDesk..."
            nohup rustdesk >/dev/null 2>&1 &
        else
            # Fallback: AppImage
            echo "No .deb for amd64 found, falling back to AppImage..."
            RUST_APPIMAGE=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep browser_download_url | grep -i "appimage" | grep -i "amd64\|x86_64" | cut -d '"' -f4 | head -n 1)
            if [ -z "$RUST_APPIMAGE" ]; then
                echo "Could not find AppImage either. Please download and install manually from https://rustdesk.com"
                echo
                read -n 1 -s -r -p "Press any key to return to the main menu..."
                main_menu
            fi
            TMPAPP=$(mktemp /tmp/rustdesk_XXXX.AppImage)
            curl -L "$RUST_APPIMAGE" -o "$TMPAPP"
            chmod +x "$TMPAPP"
            echo "Launching RustDesk AppImage..."
            nohup "$TMPAPP" >/dev/null 2>&1 &
        fi
    elif [ "$PLATFORM" = "mac" ]; then
        echo "Installing RustDesk (Mac)..."
        RUST_URL=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep browser_download_url | grep darwin_x86_64.dmg | cut -d '"' -f4 | head -n 1)
        if [ -z "$RUST_URL" ]; then
            echo "Could not find latest RustDesk .dmg download link."
            echo
            read -n 1 -s -r -p "Press any key to return to the main menu..."
            main_menu
        fi
        TMPDMG=$(mktemp /tmp/rustdesk_XXXX.dmg)
        curl -L "$RUST_URL" -o "$TMPDMG"
        hdiutil attach "$TMPDMG" -nobrowse
        cp -R "/Volumes/RustDesk/RustDesk.app" /Applications/
        hdiutil detach "/Volumes/RustDesk"
        rm -f "$TMPDMG"
        echo "Launching RustDesk..."
        open -a RustDesk
    fi
    echo
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

uninstall_all() {
    detect_os
    if [ "$PLATFORM" = "linux" ]; then
        echo "Uninstalling AnyDesk..."
        sudo apt-get remove --purge -y anydesk || true
        sudo rm -f /etc/apt/sources.list.d/anydesk.list
        sudo rm -f /usr/share/keyrings/anydesk-archive-keyring.gpg
        sudo apt-get autoremove -y
        echo "Uninstalling RustDesk..."
        sudo apt-get remove --purge -y rustdesk || true
        sudo apt-get autoremove -y
        # Clean any AppImage temp leftovers
        rm -f /tmp/rustdesk_*.AppImage
    elif [ "$PLATFORM" = "mac" ]; then
        echo "Uninstalling AnyDesk..."
        sudo rm -rf /Applications/AnyDesk.app
        echo "Uninstalling RustDesk..."
        sudo rm -rf /Applications/RustDesk.app
    fi
    echo "Cleanup complete."
    echo
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

main_menu
