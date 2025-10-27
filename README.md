English | [中文](./README_ZH.md)

# UFW-Docker (ufwd)

A UFW wrapper script specifically designed for managing Docker container port firewall rules. The command format is fully compatible with `ufw`, providing zero learning curve.

## Why This Tool?

Docker's port mapping bypasses UFW's control because Docker directly modifies iptables rules. This tool solves the compatibility issue by modifying UFW's configuration file `after.rules` and implementing forward-based filtering through the `DOCKER-USER` chain. This approach allows UFW to properly manage Docker container port access while maintaining security.

## Quick Start

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/install.sh | sudo bash
```

### Initialization

```bash
sudo ufwd init
```

This will backup your current `/etc/ufw/after.rules` and `/etc/ufw/after6.rules` and replace them with initial versions.

### Usage

```bash
# Add rules
sudo ufwd allow 80/tcp
sudo ufwd allow 443/tcp from 173.245.48.0/20

# Delete rules
sudo ufwd delete allow 80/tcp

# View rules
sudo ufwd status

# Apply changes
sudo systemctl restart ufw
```

## Key Features

- ✅ **Zero Learning Curve**: Command format is fully compatible with `ufw`
- ✅ **Automatic Management**: Rules are automatically added to designated sections
- ✅ **Smart Detection**: Automatically distinguishes between IPv4 and IPv6 rules
- ✅ **Safe Backup**: Automatic backup of original files during initialization

## Command Format

### Basic Commands

```bash
# Add allow rules
sudo ufwd allow 80/tcp
sudo ufwd allow 443/tcp from 173.245.48.0/20

# Add deny rules
sudo ufwd deny 3306/tcp

# Delete rules
sudo ufwd delete allow 80/tcp
sudo ufwd delete deny 3306/tcp

# Other commands
sudo ufwd status
sudo ufwd enable
sudo ufwd disable
```

### Initialization Commands

```bash
# Initialize (backup and replace rule files)
sudo ufwd init

# Restore original files
sudo ufwd uninit
```

## Important Notes

⚠️ **You must restart UFW after each rule addition or deletion:**

```bash
sudo systemctl restart ufw
```

⚠️ **Backup file locations:**

```
/etc/ufw/after.rules_original
/etc/ufw/after6.rules_original
```

## Troubleshooting

### Rules Not Taking Effect

1. Ensure UFW has been restarted: `sudo systemctl restart ufw`
2. Check rules: `sudo cat /etc/ufw/after.rules | grep DOCKER-USER`
3. View status: `sudo ufwd status`

### Restore Original Configuration

```bash
sudo ufwd uninit
```

## License

This project aims to solve compatibility issues between Docker and UFW, making Docker container port management more convenient and secure.
