# UFWD 命令覆盖说明

本文档说明 `ufwd` 如何处理 UFW 的所有命令。

## UFWD 特有的命令

### `ufwd init`
- **功能**: 初始化 ufwd 规则文件
- **动作**: 备份当前 `/etc/ufw/after.rules` 和 `/etc/ufw/after6.rules`，并用初始版本替换
- **ufwd 特有**: ✅

## 规则管理命令（由 ufwd 处理）

这些命令会将规则添加到 "# 4️⃣ 开启容器端口" 部分：

### `ufwd allow ARGS`
- **功能**: 添加允许规则
- **处理**: ufwd 解析参数，构建 iptables 规则，添加到规则文件
- **支持格式**: 
  - `ufwd allow 80/tcp`
  - `ufwd allow 80/tcp from 192.168.1.0/24`
  - 与 `ufw allow` 完全一致的格式

### `ufwd deny ARGS`
- **功能**: 添加拒绝规则
- **处理**: 同 allow，但目标是 DROP

### `ufwd reject ARGS`
- **功能**: 添加拒绝规则（带 ICMP 响应）
- **处理**: 同 allow，但目标是 REJECT

### `ufwd delete allow ARGS`
- **功能**: 删除允许规则
- **处理**: ufwd 查找匹配的规则并从 "# 4️⃣ 开启容器端口" 部分删除

### `ufwd delete deny ARGS`
- **功能**: 删除拒绝规则
- **处理**: 同 delete allow

### `ufwd delete reject ARGS`
- **功能**: 删除拒绝规则
- **处理**: 同 delete allow

### `ufwd delete NUM` (numbered delete)
- **功能**: 按编号删除规则
- **处理**: 直接传递给 `ufw`（不通过 ufwd 管理）

## 传递给 UFW 的命令

所有其他命令都直接传递给 `ufw`，由 UFW 原生处理。

### 状态查看
- `status` - 显示防火墙状态
- `status numbered` - 显示带编号的规则列表
- `status verbose` - 显示详细状态
- `show ARG` - 显示防火墙报告

### 启用/禁用
- `enable` - 启用防火墙
- `disable` - 禁用防火墙

### 配置管理
- `default ARG` - 设置默认策略
- `logging LEVEL` - 设置日志级别

### 防火墙操作
- `reload` - 重新加载防火墙配置
- `reset` - 重置防火墙配置

### 规则位置操作
这些命令会操作 UFW 的主规则列表，**不使用** ufwd 的管理方式：

- `insert NUM RULE` - 在指定位置插入规则
- `prepend RULE` - 在规则列表前添加规则

**为什么传递给 ufw**: 这些命令用于精确控制规则位置，与 ufwd 的"添加到固定部分"的模型不兼容。

### 路由规则
- `route RULE` - 添加路由规则
- `route delete RULE|NUM` - 删除路由规则
- `route insert NUM RULE` - 插入路由规则

**为什么传递给 ufw**: 路由规则用于 NAT，是 UFW 的原生功能，ufwd 专注于端口访问控制。

### 限制规则
- `limit ARGS` - 添加限流规则

**为什么传递给 ufw**: 限流规则通常用于保护 SSH 等服务，不常用于 Docker 容器的端口管理。

### 应用配置
- `app list` - 列出应用配置
- `app info PROFILE` - 显示应用配置信息
- `app update PROFILE` - 更新应用配置
- `app default ARG` - 设置默认应用策略

**为什么传递给 ufw**: 应用配置是 UFW 的高级功能，用于预定义的服务配置。

### 版本和帮助
- `version` - 显示版本信息
- `help` - 显示帮助信息
- `--help`, `-h` - 同 help

## 命令映射表

| UFW 命令 | UFWD 处理方式 | 说明 |
|---------|--------------|------|
| `init` | ufwd 特有 | 初始化规则文件 |
| `allow` | ufwd 处理 | 添加到固定部分 |
| `deny` | ufwd 处理 | 添加到固定部分 |
| `reject` | ufwd 处理 | 添加到固定部分 |
| `delete allow/deny/reject` | ufwd 处理 | 从固定部分删除 |
| `delete NUM` | 转发给 ufw | 编号删除 |
| `limit` | 转发给 ufw | 不常用 |
| `insert` | 转发给 ufw | 位置操作 |
| `prepend` | 转发给 ufw | 位置操作 |
| `route` | 转发给 ufw | NAT 功能 |
| `route delete` | 转发给 ufw | NAT 功能 |
| `route insert` | 转发给 ufw | NAT 功能 |
| `status` | 转发给 ufw | 状态查看 |
| `status numbered` | 转发给 ufw | 状态查看 |
| `status verbose` | 转发给 ufw | 状态查看 |
| `show` | 转发给 ufw | 报告查看 |
| `enable` | 转发给 ufw | 启用防火墙 |
| `disable` | 转发给 ufw | 禁用防火墙 |
| `default` | 转发给 ufw | 默认策略 |
| `logging` | 转发给 ufw | 日志级别 |
| `reload` | 转发给 ufw | 重新加载 |
| `reset` | 转发给 ufw | 重置配置 |
| `app` | 转发给 ufw | 应用配置 |
| `version` | 转发给 ufw (+ ufwd 标识) | 版本信息 |
| `help` | ufwd 自定义 | ufwd 帮助 |

## 设计原则

1. **保持与 UFW 的完全兼容**: 所有 UFW 命令都可以在 `ufwd` 中使用
2. **专注核心功能**: ufwd 专注于端口访问控制，复杂功能交给 UFW
3. **零学习成本**: UFW 用户可以直接使用，无需学习新命令
4. **清晰的组织**: 端口相关的规则统一管理在固定部分

## 使用建议

### 推荐使用 ufwd 处理的命令

```bash
# Docker 容器的端口访问控制
sudo ufwd allow 80/tcp
sudo ufwd allow 443/tcp from 173.245.48.0/20
sudo ufwd deny 3306/tcp
sudo ufwd delete allow 80/tcp
```

### 使用原 UFW 命令的情况

```bash
# 精确位置控制
sudo ufw insert 1 allow 22/tcp

# NAT 和路由
sudo ufw route allow from 10.0.0.0/8

# SSH 保护（限流）
sudo ufw limit 22/tcp

# 应用配置
sudo ufw app list
sudo ufw allow OpenSSH
```

### 两者混用

`ufwd` 和 `ufw` 可以安全地混用。例如：

```bash
# 用 ufwd 管理 Docker 端口
sudo ufwd allow 80/tcp

# 用 ufw 管理 SSH 访问
sudo ufw limit 22/tcp

# 查看所有规则
sudo ufw status
```

**唯一注意事项**: 修改规则后要重启 UFW: `sudo systemctl restart ufw`
