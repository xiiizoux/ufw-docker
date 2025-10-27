[English](./README.md) | 中文

# UFW-Docker (ufwd)

专门用于管理 Docker 容器端口防火墙规则的 UFW 包装脚本。命令格式与 `ufw` 完全一致，实现零学习成本。

## 快速开始

### 安装

```bash
curl -fsSL https://raw.githubusercontent.com/xiiizoux/ufw-docker/refs/heads/main/install.sh | sudo bash
```

### 初始化

```bash
sudo ufwd init
```

这会备份当前的 `/etc/ufw/after.rules` 和 `/etc/ufw/after6.rules`，并用初始版本替换。

### 使用

```bash
# 添加规则
sudo ufwd allow 80/tcp
sudo ufwd allow 443/tcp from 173.245.48.0/20

# 删除规则
sudo ufwd delete allow 80/tcp

# 查看规则
sudo ufwd status

# 应用更改
sudo systemctl restart ufw
```

## 主要功能

- ✅ **零学习成本**: 命令格式与 `ufw` 完全一致
- ✅ **自动管理**: 规则自动添加到指定位置
- ✅ **智能识别**: 自动区分 IPv4 和 IPv6 规则
- ✅ **安全备份**: 初始化时自动备份原文件

## 命令格式

### 基本命令

```bash
# 添加允许规则
sudo ufwd allow 80/tcp
sudo ufwd allow 443/tcp from 173.245.48.0/20

# 添加拒绝规则
sudo ufwd deny 3306/tcp

# 删除规则
sudo ufwd delete allow 80/tcp
sudo ufwd delete deny 3306/tcp

# 其他命令
sudo ufwd status
sudo ufwd enable
sudo ufwd disable
```

### 初始化命令

```bash
# 初始化（备份并替换规则文件）
sudo ufwd init

# 恢复原始文件
sudo ufwd uninit
```

## 重要提示

⚠️ **每次添加或删除规则后，必须重启 UFW：**

```bash
sudo systemctl restart ufw
```

⚠️ **备份文件位置：**

```
/etc/ufw/after.rules_original
/etc/ufw/after6.rules_original
```

## 故障排除

### 规则没有生效

1. 确认已重启 UFW: `sudo systemctl restart ufw`
2. 检查规则: `sudo cat /etc/ufw/after.rules | grep DOCKER-USER`
3. 查看状态: `sudo ufwd status`

### 恢复原始配置

```bash
sudo ufwd uninit
```

## 许可证

本项目旨在解决 Docker 与 UFW 的兼容性问题，使 Docker 容器的端口管理更方便、更安全。

