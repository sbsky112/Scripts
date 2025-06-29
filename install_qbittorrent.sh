#!/bin/bash

# Ubuntu 24.04 一键安装 qBittorrent-nox
# 作者: sbsky112
# 默认用户名: admin，密码: ，下载目录: /root/Downloads

set -e

echo "✅ 开始安装 qBittorrent..."

# 检查是否为 root
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ 请以 root 用户运行此脚本"
  exit 1
fi

# 安装 qBittorrent-nox
apt update && apt install -y qbittorrent-nox

# 停止服务防止覆盖配置（如果有）
systemctl stop qbittorrent.service 2>/dev/null || true

# 清理旧配置
rm -rf /root/.config/qBittorrent

# 创建目录
mkdir -p /root/.config/qBittorrent
mkdir -p /root/Downloads

# 写入默认配置（用户名：admin，密码：）
cat > /root/.config/qBittorrent/qBittorrent.conf <<EOF
[Preferences]
Connection\PortRangeMin=6881
Downloads\SavePath=/root/Downloads/
WebUI\Port=8080
WebUI\Username=admin
WebUI\Password_ha1=@ByteArray(4850734fbd9e43b173aeb06c79b0572b)
WebUI\CSRFProtection=false
WebUI\ClickjackingProtection=false
EOF

# 创建 systemd 服务
cat > /etc/systemd/system/qbittorrent.service <<EOF
[Unit]
Description=qBittorrent-nox Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/qbittorrent-nox
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
systemctl daemon-reload
systemctl enable qbittorrent
systemctl start qbittorrent

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "🎉 qBittorrent 安装完成！"
echo "🌐 Web UI 地址: http://${IP}:8080"
echo "👤 用户名: admin"
echo "🔑 密码: "
echo "📁 下载目录: /root/Downloads"
