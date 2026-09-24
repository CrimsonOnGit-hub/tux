#!/usr/bin/env bash
# Tux Package Manager Installer
set -e

echo -e "\033[1;36m========================================================\033[0m"
echo -e "\033[1;36m          Installing Tux Universal Package Manager      \033[0m"
echo -e "\033[1;36m========================================================\033[0m"

# Verify root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;31m[-] Error: Please run the installer as root (e.g., sudo ./install.sh)\033[0m"
    exit 1
fi

INSTALL_DIR="/usr/local/bin"
DATA_DIR="/var/lib/tux"

# Verify python3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "\033[1;33m[!] Python 3 is required but not installed. Attempting to install via apt...\033[0m"
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y python3
    else
        echo -e "\033[1;31m[-] Error: Please install python3 manually first.\033[0m"
        exit 1
    fi
fi

# Create data directory and lockfile
mkdir -p "$DATA_DIR"
if [ ! -f "$DATA_DIR/lock.json" ]; then
    echo '{"installed": {}}' > "$DATA_DIR/lock.json"
fi

# Copy executable
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/tux" ]; then
    cp "$SCRIPT_DIR/tux" "$INSTALL_DIR/tux"
else
    echo -e "[+] Fetching latest tux binary from GitHub repository..."
    curl -fsSL https://raw.githubusercontent.com/CrimsonOnGit-hub/tux/main/tux -o "$INSTALL_DIR/tux"
fi

chmod +x "$INSTALL_DIR/tux"

echo -e "\033[1;32m[+] Tux successfully installed to $INSTALL_DIR/tux\033[0m"
echo -e "\033[1;36mTry running:\033[0m"
echo -e "  tux list"
echo -e "  tux info fastfetch"
echo -e "  sudo tux install fastfetch"
