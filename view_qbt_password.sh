#!/bin/bash
set -e

echo "正在尝试提取 qBittorrent Web UI 登录信息..."

# 提取包含密码的日志行
PASSWORD_LINE=$(journalctl -u qbittorrent-nox -n 100 --no-pager | grep "temporary password is provided for this session" | tail -1)

# 提取用户名（可选）
USERNAME_LINE=$(journalctl -u qbittorrent-nox -n 100 --no-pager | grep "administrator username is:" | tail -1)

if [[ $PASSWORD_LINE =~ session:\ ([^[:space:]]+) ]]; then
  PASSWORD="${BASH_REMATCH[1]}"
  echo "✅ Web UI 默认用户名: admin"
  echo "🔑 随机密码: $PASSWORD"
  echo "🌐 访问地址示例: http://<你的服务器IP>:8080"
else
  echo "❌ 未找到最近的密码信息，请确保 qBittorrent-nox 正常运行。"
  echo "你可以手动查看日志：journalctl -u qbittorrent-nox -n 100 --no-pager"
fi
