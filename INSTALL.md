# 安装指南

## 快速安装

### 方法 1: 使用安装脚本（推荐）

```bash
# 一行命令安装
curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/install.sh | sudo bash
```

### 方法 2: 手动下载安装

```bash
# 下载安装脚本
curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/install.sh -o /tmp/install-ufwd.sh

# 运行安装
sudo bash /tmp/install-ufwd.sh
```

## 安装内容

安装脚本会：
1. 下载 `ufwd` 脚本到 `/usr/local/bin/ufwd`
2. 下载 `after.rules` 和 `after6.rules` 到 `/usr/local/share/ufwd/`
3. 设置执行权限

## 安装后步骤

### 1. 初始化 ufwd

```bash
sudo ufwd init
```

这会：
- 备份当前 `/etc/ufw/after.rules` 为 `after.rules_original`
- 备份当前 `/etc/ufw/after6.rules` 为 `after6.rules_original`
- 用 ufwd 兼容版本替换它们

### 2. 重启 UFW

```bash
sudo systemctl restart ufw
```

## 验证安装

```bash
# 检查 ufwd 是否安装
which ufwd

# 查看帮助
ufwd help

# 查看 UFW 状态
ufwd status
```

## 卸载

如果需要卸载：

```bash
# 恢复原始文件
sudo ufwd uninit

# 删除 ufwd
sudo rm /usr/local/bin/ufwd
sudo rm -rf /usr/local/share/ufwd
```

## 手动安装（不使用脚本）

如果你不想使用安装脚本，也可以手动安装：

```bash
# 1. 下载 ufwd
sudo curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/ufwd -o /usr/local/bin/ufwd
sudo chmod +x /usr/local/bin/ufwd

# 2. 创建目录并下载规则文件
sudo mkdir -p /usr/local/share/ufwd
sudo curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/after.rules -o /usr/local/share/ufwd/after.rules
sudo curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/after6.rules -o /usr/local/share/ufwd/after6.rules

# 3. 初始化
sudo ufwd init
sudo systemctl restart ufw
```

## 文件位置

- `ufwd` 可执行文件: `/usr/local/bin/ufwd`
- 初始化规则文件: `/usr/local/share/ufwd/`
  - `after.rules` (IPv4)
  - `after6.rules` (IPv6)
- UFW 规则文件: `/etc/ufw/`
  - `after.rules`
  - `after6.rules`
  - `after.rules_original` (备份)
  - `after6.rules_original` (备份)

## 系统要求

- Linux 系统
- UFW (Uncomplicated Firewall)
- Docker
- curl (用于下载)
- sudo 权限

## 故障排除

### curl 未安装

```bash
# Ubuntu/Debian
sudo apt-get install curl

# CentOS/RHEL
sudo yum install curl
```

### 下载失败

如果 GitHub 访问有问题，请检查：
1. 网络连接
2. 防火墙设置
3. 可能需要使用代理

