#!/bin/bash

# Ubuntu 24.04 一键安装 qBittorrent (nox版)
# 下载目录: /root/Downloads

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ 请以 root 用户运行此脚本"
  exit 1
fi

echo "✅ 更新系统..."
apt update && apt upgrade -y

echo "✅ 安装 qbittorrent-nox..."
apt install -y qbittorrent-nox

echo "✅ 创建下载目录 /root/Downloads..."
mkdir -p /root/Downloads

echo "✅ 创建 systemd 服务..."
cat > /etc/systemd/system/qbittorrent.service <<EOF
[Unit]
Description=qBittorrent (nox) service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/qbittorrent-nox
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

CONFIG_PATH="/root/.config/qBittorrent/qBittorrent.conf"
mkdir -p "$(dirname "$CONFIG_PATH")"

echo "✅ 写入配置..."
cat > "$CONFIG_PATH" <<EOF
[Preferences]
Connection\PortRangeMin=6881
Downloads\SavePath=/root/Downloads/
WebUI\Port=8080
WebUI\Username=admin
WebUI\Password_ha1=@ByteArray(4850734fbd9e43b173aeb06c79b0572b)
WebUI\CSRFProtection=false
WebUI\ClickjackingProtection=false
EOF

echo "✅ 启动服务..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable qbittorrent
systemctl restart qbittorrent

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "🎉 qBittorrent 安装并已启动！"
echo "🌐 Web UI: http://${IP}:8080"
echo "👤 用户名: admin"
echo "🔑 密码: "
echo "📁 下载保存目录: /root/Downloads"
