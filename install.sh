#!/bin/bash
# Installation script for ufwd

set -e

INSTALL_DIR="/usr/local/bin"
SHARE_DIR="/usr/local/share/ufwd"
GITHUB_BASE="https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main"

echo "Installing ufwd..."

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root" 
   echo "Please run: sudo $0"
   exit 1
fi

# Check for curl
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not installed."
    echo "Please install curl first:"
    echo "  Ubuntu/Debian: sudo apt-get install curl"
    echo "  CentOS/RHEL: sudo yum install curl"
    exit 1
fi

# Function to download with error handling
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"
    
    echo "Downloading $description..."
    
    if curl -fsSL --connect-timeout 10 --max-time 30 --retry 2 "$url" -o "$output" 2>/dev/null; then
        echo "✓ Downloaded $description"
        return 0
    else
        local status_code
        status_code=$(curl -sSLo /dev/null -w "%{http_code}" --connect-timeout 10 "$url" 2>/dev/null || echo "000")
        
        echo "ERROR: Failed to download $description"
        echo "  URL: $url"
        echo "  Status code: $status_code"
        echo ""
        echo "Possible reasons:"
        echo "  - Network connection issue"
        echo "  - GitHub is not accessible"
        echo "  - Firewall blocking the connection"
        echo ""
        echo "You can try:"
        echo "  1. Check your network connection"
        echo "  2. Use a proxy if behind a firewall"
        echo "  3. Install manually using git clone"
        
        if [[ -f "$output" ]]; then
            rm -f "$output"
        fi
        
        return 1
    fi
}

# Download and install the script
if [[ -f "${INSTALL_DIR}/ufwd" ]]; then
    echo "Updating existing ufwd installation..."
else
    echo "Installing ufwd..."
fi

if ! download_file "${GITHUB_BASE}/ufwd" "${INSTALL_DIR}/ufwd" "ufwd"; then
    exit 1
fi

chmod +x "${INSTALL_DIR}/ufwd"
echo "✓ Installed ${INSTALL_DIR}/ufwd"

# Install init files
echo ""
echo "Setting up init files..."
echo "Creating ${SHARE_DIR}..."
mkdir -p "${SHARE_DIR}"

if ! download_file "${GITHUB_BASE}/after.rules" "${SHARE_DIR}/after.rules" "after.rules"; then
    echo "WARNING: Failed to download after.rules"
    echo "You can download it manually later."
fi

if ! download_file "${GITHUB_BASE}/after6.rules" "${SHARE_DIR}/after6.rules" "after6.rules"; then
    echo "WARNING: Failed to download after6.rules"
    echo "You can download it manually later."
fi

echo "✓ Init files ready in ${SHARE_DIR}"

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Initialize ufwd (backup and setup UFW files):"
echo "   sudo ufwd init"
echo ""
echo "2. Restart UFW to apply changes:"
echo "   sudo systemctl restart ufw"
echo ""
echo "3. Start managing Docker ports:"
echo "   sudo ufwd allow 80/tcp"
echo "   sudo ufwd status"
echo ""
echo "For more information:"
echo "   sudo ufwd help"

