#!/bin/bash

# Remote Support Installer for macOS and Linux
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}=== Remote Support Installer for macOS and Linux ==="
echo -e "============================================${NC}"
echo ""

# Platform detection
PLATFORM=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="Linux"
else
    echo -e "${RED}Unsupported operating system${NC}"
    exit 1
fi

echo -e "${YELLOW}Detected platform: $PLATFORM${NC}"
echo ""
echo "Choose application to install:"
echo "1) AnyDesk"
echo "2) RustDesk"
echo -n "Enter your choice (1 or 2): "
read APP_CHOICE

echo ""
case $APP_CHOICE in
    1)
        APP="AnyDesk"
        ;;
    2)
        APP="RustDesk"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}Selected application: $APP${NC}"
echo ""

install_anydesk_macos() {
    echo "Downloading AnyDesk..."
    curl -o anydesk.dmg "https://download.anydesk.com/anydesk.dmg?os=mac" -L
    echo "Mounting installer..."
    hdiutil attach anydesk.dmg
    echo "Copying to Applications..."
    cp -R "/Volumes/AnyDesk/AnyDesk.app" /Applications
    echo "Cleaning up..."
    hdiutil detach "/Volumes/AnyDesk"
    rm anydesk.dmg
}

install_rustdesk_macos() {
    echo "Downloading RustDesk..."
    curl -o rustdesk.dmg "https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk.dmg" -L
    echo "Mounting installer..."
    hdiutil attach rustdesk.dmg
    echo "Copying to Applications..."
    cp -R "/Volumes/RustDesk/RustDesk.app" /Applications
    echo "Cleaning up..."
    hdiutil detach "/Volumes/RustDesk"
    rm rustdesk.dmg
}

install_anydesk_linux() {
    echo "Adding AnyDesk repository..."
    wget -qO- https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/anydesk.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list
    echo "Updating packages..."
    sudo apt update
    echo "Installing AnyDesk..."
    sudo apt install anydesk -y
}

install_rustdesk_linux() {
    echo "Downloading RustDesk..."
    wget https://github.com/rustdesk/rustdesk/releases/latest/download/rustdesk.deb
    echo "Installing RustDesk..."
    sudo apt install ./rustdesk.deb -y
    echo "Cleaning up..."
    rm rustdesk.deb
}

# Main installation
echo -e "${YELLOW}Starting installation...${NC}"
echo ""

if [[ "$PLATFORM" == "macOS" ]]; then
    if [[ "$APP" == "AnyDesk" ]]; then
        install_anydesk_macos
    else
        install_rustdesk_macos
    fi
elif [[ "$PLATFORM" == "Linux" ]]; then
    if [[ "$APP" == "AnyDesk" ]]; then
        install_anydesk_linux
    else
        install_rustdesk_linux
    fi
fi

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "Please launch ${CYAN}$APP${NC} from your applications menu."