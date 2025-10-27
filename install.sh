#!/bin/bash
# Installation script for ufwd

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/ufwd"

echo "Installing ufwd..."

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   echo "Please run: sudo $0"
   exit 1
fi

# Install the script
echo "Copying ufwd to $INSTALL_DIR..."
cp "$SCRIPT_DIR/ufwd" "$INSTALL_DIR/ufwd"
chmod +x "$INSTALL_DIR/ufwd"
echo "✓ Installed $INSTALL_DIR/ufwd"

# Install init files
echo "Creating $SHARE_DIR..."
mkdir -p "$SHARE_DIR"

echo "Copying init files..."
cp "$SCRIPT_DIR/after.rules" "$SHARE_DIR/after.rules"
cp "$SCRIPT_DIR/after6.rules" "$SHARE_DIR/after6.rules"
echo "✓ Installed init files to $SHARE_DIR"

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

