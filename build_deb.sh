#!/usr/bin/env bash
# ==============================================================================
# Tux .deb Package Builder for APT & Debian/Ubuntu/WSL Systems
# ==============================================================================
set -e

VERSION="1.0.0"
PACKAGE_NAME="tux"
ARCH="all"
DIST_DIR="$(pwd)/dist"
BUILD_ROOT="/tmp/tux_deb_build"
PKG_DIR="${BUILD_ROOT}/${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "========================================================"
echo "          Building Tux .deb Package (v${VERSION})       "
echo "========================================================"

# Clean previous build artifacts
rm -rf "$BUILD_ROOT"
mkdir -p "$DIST_DIR"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/local/bin"
mkdir -p "${PKG_DIR}/var/lib/tux"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify tux.py exists
if [ ! -f "$SCRIPT_DIR/tux.py" ]; then
    echo "[-] Error: 'tux.py' not found in $SCRIPT_DIR."
    exit 1
fi

# 1. Determine payload packaging mode (PyInstaller standalone binary or direct Python executable)
if command -v pyinstaller &> /dev/null; then
    echo "[+] PyInstaller detected. Compiling standalone binary..."
    TEMP_PYI="/tmp/tux_pyi_build"
    rm -rf "$TEMP_PYI"
    mkdir -p "$TEMP_PYI"
    cp "$SCRIPT_DIR/tux.py" "$TEMP_PYI/"
    (cd "$TEMP_PYI" && pyinstaller --onefile tux.py)
    cp "$TEMP_PYI/dist/tux" "${PKG_DIR}/usr/local/bin/tux"
    rm -rf "$TEMP_PYI"
else
    echo "[+] Copying tux.py directly to /usr/local/bin/tux..."
    cp "$SCRIPT_DIR/tux.py" "${PKG_DIR}/usr/local/bin/tux"
fi

chmod 755 "${PKG_DIR}/usr/local/bin/tux"

# 2. Generate DEBIAN/control file
echo "[+] Writing DEBIAN/control manifest..."
cat << 'EOF' > "${PKG_DIR}/DEBIAN/control"
Package: tux
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Depends: python3
Maintainer: Crimson <allaboutgames2268@gmail.com>
Homepage: https://github.com/CrimsonOnGit-hub/tux
Description: Tux Universal Package Manager
 A fast, lightweight, and colored package manager built for Linux and WSL.
 Pulls packages directly from remote repository catalogs and installs them
 seamlessly.
EOF

# 3. Generate DEBIAN/postinst (Post-installation hook)
echo "[+] Writing DEBIAN/postinst hook..."
cat << 'EOF' > "${PKG_DIR}/DEBIAN/postinst"
#!/bin/sh
set -e
mkdir -p /var/lib/tux
if [ ! -f /var/lib/tux/lock.json ]; then
    echo '{"installed": {}}' > /var/lib/tux/lock.json
fi
chmod 755 /var/lib/tux
chmod 644 /var/lib/tux/lock.json 2>/dev/null || true
ln -sf /usr/local/bin/tux /usr/local/bin/Tux
chmod 755 /usr/local/bin/tux
exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/postinst"

# 4. Generate DEBIAN/prerm (Pre-removal hook)
echo "[+] Writing DEBIAN/prerm hook..."
cat << 'EOF' > "${PKG_DIR}/DEBIAN/prerm"
#!/bin/sh
set -e
rm -f /usr/local/bin/Tux
exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/prerm"

# 5. Build the .deb archive using dpkg-deb
echo "[+] Assembling debian package..."
dpkg-deb --build --root-owner-group "$PKG_DIR" "$DIST_DIR/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

# 6. Cleanup temporary staging directory
rm -rf "$BUILD_ROOT"

echo ""
echo "========================================================"
echo "  [SUCCESS] Package built successfully!"
echo "  Location: $DIST_DIR/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
echo "========================================================"
echo ""
echo "To test installation on your system with APT:"
echo "  sudo apt install ./dist/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
