#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "[*] Initializing Tux Installation Sequence..."

# 1. Enforce root execution
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: Please run this installer with root privileges (e.g., sudo ./install.sh)"
    exit 1
fi

# Detect actual non-root invoking user (for installing user-level pip packages cleanly)
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

# 2. Check and install Python 3 & pip
echo "[+] Checking for Python 3..."
if ! command -v python3 &> /dev/null; then
    echo "[!] Python 3 not found. Installing python3 and python3-pip..."
    apt-get update -y
    apt-get install -y python3 python3-pip python3-venv
else
    echo "[+] Python 3 is installed."
fi

# Ensure pip3 is available
if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
    echo "[!] pip not found. Installing python3-pip..."
    apt-get update -y
    apt-get install -y python3-pip
fi

# 3. Check and install PyInstaller
echo "[+] Checking for PyInstaller..."
PYINSTALLER_BIN=""

if command -v pyinstaller &> /dev/null; then
    PYINSTALLER_BIN="pyinstaller"
elif [ -f "$USER_HOME/.local/bin/pyinstaller" ]; then
    PYINSTALLER_BIN="$USER_HOME/.local/bin/pyinstaller"
elif [ -f "/usr/local/bin/pyinstaller" ]; then
    PYINSTALLER_BIN="/usr/local/bin/pyinstaller"
else
    echo "[!] PyInstaller not found. Installing PyInstaller via pip..."
    # Install PyInstaller (using --break-system-packages if on newer Debian/Ubuntu releases)
    pip3 install pyinstaller --break-system-packages 2>/dev/null || pip3 install pyinstaller
    
    if [ -f "$USER_HOME/.local/bin/pyinstaller" ]; then
        PYINSTALLER_BIN="$USER_HOME/.local/bin/pyinstaller"
    elif command -v pyinstaller &> /dev/null; then
        PYINSTALLER_BIN="pyinstaller"
    else
        PYINSTALLER_BIN="$(find / -name pyinstaller -type f -executable 2>/dev/null | head -n 1)"
    fi
fi

if [ -z "$PYINSTALLER_BIN" ]; then
    echo "[-] Fatal Error: PyInstaller installation succeeded but binary could not be resolved."
    exit 1
fi

echo "[+] PyInstaller ready at: $PYINSTALLER_BIN"

# 4. Locate source directory and stage to /tmp/tux_build
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="/tmp/tux_build"

if [ ! -f "$SCRIPT_DIR/tux.py" ]; then
    echo "[-] Error: 'tux.py' not found in $SCRIPT_DIR. Make sure install.sh is in the same folder as tux.py."
    exit 1
fi

echo "[+] Staging build files to $BUILD_DIR..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r "$SCRIPT_DIR/"* "$BUILD_DIR/"

# 5. Compile with PyInstaller
echo "[+] Compiling Tux standalone binary..."
cd "$BUILD_DIR"
$PYINSTALLER_BIN --onefile tux.py

if [ ! -f "$BUILD_DIR/dist/tux" ]; then
    echo "[-] Compilation failed: $BUILD_DIR/dist/tux was not generated."
    exit 1
fi

# 6. Install to /usr/local/bin and setup symlinks
echo "[+] Installing Tux to /usr/local/bin..."
cp "$BUILD_DIR/dist/tux" /usr/local/bin/tux
chmod +x /usr/local/bin/tux

# Create case-insensitive symlink so both 'tux' and 'Tux' execute
ln -sf /usr/local/bin/tux /usr/local/bin/Tux

# 7. Initialize data directory
mkdir -p /var/lib/tux
if [ ! -f /var/lib/tux/lock.json ]; then
    echo '{"installed": {}}' > /var/lib/tux/lock.json
fi

# 8. Cleanup temporary build files
echo "[+] Cleaning up build artifacts..."
rm -rf "$BUILD_DIR"

echo "========================================"
echo "Done! Tux successfully installed."
echo "You can now run 'tux' or 'Tux' globally."
echo "========================================"
exit 0
