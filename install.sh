#!/bin/bash
# Installation script for ufwd

set -e

INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/ufwd"
GITHUB_BASE="https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main"

echo "Installing ufwd..."

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   echo "Please run: sudo $0"
   exit 1
fi

# Check for curl
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not installed."
    echo "Please install curl first: sudo apt-get install curl"
    exit 1
fi

# Download and install the script
echo "Downloading ufwd from GitHub..."
curl -fsSL "${GITHUB_BASE}/ufwd" -o "${INSTALL_DIR}/ufwd"
chmod +x "${INSTALL_DIR}/ufwd"
echo "✓ Installed ${INSTALL_DIR}/ufwd"

# Install init files
echo "Creating ${SHARE_DIR}..."
mkdir -p "${SHARE_DIR}"

echo "Downloading init files..."
curl -fsSL "${GITHUB_BASE}/after.rules" -o "${SHARE_DIR}/after.rules"
curl -fsSL "${GITHUB_BASE}/after6.rules" -o "${SHARE_DIR}/after6.rules"
echo "✓ Installed init files to ${SHARE_DIR}"

echo ""
echo "Installation complete!"
echo ""
echo "To initialize ufwd, run:"
echo "  sudo ufwd init"
echo ""
echo "This will backup your current /etc/ufw/after.rules and"
echo "/etc/ufw/after6.rules files and replace them with the"
echo "ufwd-compatible versions."
echo ""
echo "After making changes with ufwd, always restart UFW:"
echo "  sudo systemctl restart ufw"

