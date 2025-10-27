# UFWD - UFW Docker 端口管理脚本

`ufwd` 是一个专门用于管理 Docker 容器端口在 UFW 防火墙中规则的脚本。它的命令格式与 `ufw` 完全一致，实现零学习成本。

## 安装

将 `ufwd` 复制到 `/usr/local/bin` 并确保可执行：

```bash
sudo cp ufwd /usr/local/bin/ufwd
sudo chmod +x /usr/local/bin/ufwd

# 同时复制初始化文件（可选）
sudo mkdir -p /usr/local/share/ufwd
sudo cp after.rules after6.rules /usr/local/share/ufwd/
```

## 初始化

首次使用前，需要初始化规则文件：

```bash
sudo ufwd init
```

这个命令会：
1. 备份 `/etc/ufw/after.rules` 和 `/etc/ufw/after6.rules`
2. 用初始版本替换它们
3. 提示你重启 UFW 服务

## 使用方法

### 添加规则

规则格式与 `ufw` 完全一致：

```bash
# 允许端口
sudo ufwd allow 80/tcp

# 允许端口（IPv4 或 IPv6）
sudo ufwd allow 443/tcp

# 允许来自特定网段的访问
sudo ufwd allow 80/tcp from 192.168.1.0/24

# 允许 UDP
sudo ufwd allow 53/udp

# 拒绝访问
sudo ufwd deny 3306/tcp

# 拒绝来自特定地址的访问
sudo ufwd deny 3306/tcp from 10.0.0.0/8
```

### 删除规则

```bash
# 删除规则
sudo ufwd delete allow 80/tcp

# 删除带来源的规则
sudo ufwd delete allow 80/tcp from 192.168.1.0/24
```

### 查看状态

所有其他命令会传递给 `ufw`：

```bash
# 查看状态
sudo ufwd status

# 查看详细状态
sudo ufwd status verbose

# 启用/禁用防火墙
sudo ufwd enable
sudo ufwd disable

# 重置配置
sudo ufwd reset
```

## 工作原理

- `ufwd init`: 备份并替换 `/etc/ufw/after.rules` 和 `/etc/ufw/after6.rules` 为初始版本
- `ufwd allow/deny/reject`: 添加规则到 "# 4️⃣ 开启容器端口" 部分
- `ufwd delete allow/deny`: 从 "# 4️⃣ 开启容器端口" 部分删除匹配的规则
- 其他命令: 直接传递给 `ufw`

## 重要提示

1. 添加或删除规则后，必须重启 UFW 服务才会生效：
   ```bash
   sudo systemctl restart ufw
   ```

2. 规则会被添加到 `after.rules` 和 `after6.rules` 文件中，位于 "# 4️⃣ 开启容器端口" 部分

3. 脚本会自动处理 IPv4 和 IPv6 地址

## 示例

```bash
# 初始化
sudo ufwd init

# 允许 HTTP 访问
sudo ufwd allow 80/tcp
sudo systemctl restart ufw

# 允许来自 CF 的访问
sudo ufwd allow 443/tcp from 173.245.48.0/20
sudo systemctl restart ufw

# 拒绝 MySQL 端口（仅对私有网络）
sudo ufwd deny 3306/tcp from 10.0.0.0/8
sudo systemctl restart ufw

# 删除规则
sudo ufwd delete allow 80/tcp
sudo systemctl restart ufw

# 查看当前状态
sudo ufwd status
```

