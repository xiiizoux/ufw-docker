# UFW-Docker (ufwd)

专门用于管理 Docker 容器端口防火墙规则的 UFW 包装脚本。命令格式与 `ufw` 完全一致，实现零学习成本。

## 项目结构

```
.
├── ufwd              # 主脚本，放在 /usr/local/bin/ 下
├── after.rules       # IPv4 初始化规则文件
├── after6.rules      # IPv6 初始化规则文件
├── install.sh        # 安装脚本
├── README.md         # 本文件
└── USAGE.md          # 详细使用文档
```

## 快速开始

### 1. 安装

```bash
sudo ./install.sh
```

或者手动安装：

```bash
# 复制脚本
sudo cp ufwd /usr/local/bin/ufwd
sudo chmod +x /usr/local/bin/ufwd

# 复制初始化文件（可选，脚本会自动查找）
sudo mkdir -p /usr/local/share/ufwd
sudo cp after.rules after6.rules /usr/local/share/ufwd/
```

### 2. 初始化

```bash
sudo ufwd init
```

这会备份当前的 `/etc/ufw/after.rules` 和 `/etc/ufw/after6.rules`，并用初始版本替换。

### 3. 使用

添加规则：
```bash
sudo ufwd allow 80/tcp
sudo systemctl restart ufw
```

删除规则：
```bash
sudo ufwd delete allow 80/tcp
sudo systemctl restart ufw
```

## 功能特点

### ✅ 与 UFW 完全兼容的命令格式

```bash
# 所有 ufw 命令都可以直接使用
sudo ufwd allow 80/tcp
sudo ufwd allow 80/tcp from 192.168.1.0/24
sudo ufwd deny 3306/tcp
sudo ufwd delete allow 80/tcp

# 其他命令直接传递给 ufw
sudo ufwd status
sudo ufwd enable
sudo ufwd disable
```

### ✅ 自动管理规则位置

所有通过 `ufwd` 添加/删除的规则都自动放在 `after.rules` 和 `after6.rules` 的 "# 4️⃣ 开启容器端口" 部分，保持文件结构清晰。

### ✅ 智能初始文件查找

`ufwd init` 会自动在以下位置查找初始化文件：
1. 脚本同目录
2. `/usr/local/share/ufwd/`
3. `/etc/ufwd/`
4. 当前工作目录

### ✅ IPv4 和 IPv6 支持

自动识别 IPv4 和 IPv6 地址，并在对应的规则文件中添加规则。

## 命令说明

### 自定义命令

- `ufwd init`: 初始化规则文件（备份当前文件并用初始版本替换）

### 规则管理（与 ufw 格式一致）

- `ufwd allow <规则>`: 添加允许规则到 "# 4️⃣ 开启容器端口" 部分
- `ufwd deny <规则>`: 添加拒绝规则到 "# 4️⃣ 开启容器端口" 部分
- `ufwd reject <规则>`: 添加拒绝规则（带 ICMP 响应）到 "# 4️⃣ 开启容器端口" 部分
- `ufwd delete allow/deny <规则>`: 删除指定规则

### 传递给 ufw 的命令

所有其他命令都会传递给 `ufw`，包括但不限于：

- 状态查看: `status`, `status numbered`, `status verbose`, `show`
- 启用/禁用: `enable`, `disable`
- 配置管理: `default`, `logging`
- 防火墙操作: `reload`, `reset`
- 规则位置: `insert`, `prepend` (会传递给 ufw，不使用 ufwd 的管理方式)
- 路由规则: `route`, `route delete`, `route insert`
- 限制规则: `limit` (会传递给 ufw)
- 应用配置: `app list`, `app info`, `app update`, `app default`
- 版本信息: `version`, `help`

完整的 UFW 命令文档: `man ufw`

## 规则示例

```bash
# 允许 HTTP
sudo ufwd allow 80/tcp

# 允许 HTTPS
sudo ufwd allow 443/tcp

# 允许来自特定网段
sudo ufwd allow 80/tcp from 192.168.1.0/24

# 允许来自 Cloudflare
sudo ufwd allow 443/tcp from 173.245.48.0/20

# 拒绝 MySQL
sudo ufwd deny 3306/tcp

# 拒绝私有网络访问 MySQL
sudo ufwd deny 3306/tcp from 10.0.0.0/8
```

添加规则后生成的 iptables 规则示例：
```bash
-A DOCKER-USER -p tcp -m tcp --dport 80 -j RETURN
-A DOCKER-USER -p tcp -m tcp --dport 80 -s 192.168.1.0/24 -j RETURN
```

## 重要提示

⚠️ **每次添加或删除规则后，必须重启 UFW 服务：**

```bash
sudo systemctl restart ufw
```

⚠️ **备份文件位置：**

初始化时会在同一目录下创建带时间戳的备份文件：
```
/etc/ufw/after.rules-ufwd-backup-20241027-141530
/etc/ufw/after6.rules-ufwd-backup-20241027-141530
```

## 设计原则

1. **零学习成本**: `ufwd` 命令格式与 `ufw` 完全一致
2. **清晰的组织**: 所有规则集中管理在 "# 4️⃣ 开启容器端口" 部分
3. **安全性**: 自动备份，防止误操作
4. **便捷性**: 智能查找初始化文件，简化安装过程

## 故障排除

### 找不到初始化文件

如果 `ufwd init` 提示找不到初始化文件，确保 `after.rules` 和 `after6.rules` 在以下任一位置：
- 与脚本同目录
- `/usr/local/share/ufwd/`
- `/etc/ufwd/`

### 规则没有生效

1. 确认已重启 UFW: `sudo systemctl restart ufw`
2. 检查规则是否正确添加到文件: `sudo cat /etc/ufw/after.rules | grep -A 10 "4️⃣"`
3. 查看 UFW 状态: `sudo ufwd status`

## 许可证

本项目旨在解决 Docker 与 UFW 的兼容性问题，使 Docker 容器的端口管理更方便、更安全。
