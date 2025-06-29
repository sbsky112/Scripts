#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 用户运行此脚本"
  exit 1
fi

echo "更新系统并安装 qbittorrent-nox..."
apt update
apt install -y qbittorrent-nox

echo "创建下载目录 /root/Downloads..."
mkdir -p /root/Downloads
chown root:root /root/Downloads

echo "创建 systemd 服务文件..."
cat >/etc/systemd/system/qbittorrent.service <<EOF
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

systemctl daemon-reload
systemctl enable qbittorrent

echo "首次启动 qbittorrent 服务，生成默认配置..."
systemctl start qbittorrent

echo "等待 10 秒，确保配置文件生成..."
sleep 10

echo "停止 qbittorrent 服务..."
systemctl stop qbittorrent

CONFIG_PATH="/root/.config/qBittorrent/qBittorrent.conf"
mkdir -p "$(dirname "$CONFIG_PATH")"

echo "写入自定义配置（用户名：admin，密码：）..."
cat > "$CONFIG_PATH" <<EOF
[Preferences]
Connection\PortRangeMin=6881
Downloads\SavePath=/root/Downloads/
WebUI\Port=8080
WebUI\Username=admin
WebUI\Password_PBKDF2=@ByteArray(FtoLUH9CWxuBvMhRZjJKFSDYto9F65v9D8mQNZmS3LrF5HwlUspKwR4q9F1v16PXa)
WebUI\CSRFProtection=false
WebUI\ClickjackingProtection=false
EOF

chown -R root:root /root/.config/qBittorrent
chmod 600 "$CONFIG_PATH"

echo "重新启动 qbittorrent 服务..."
systemctl start qbittorrent

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "======================================="
echo "qBittorrent 安装并配置完成！"
echo "Web UI 地址: http://${IP}:8080"
echo "用户名：admin"
echo "密码："
echo "下载目录：/root/Downloads"
echo "======================================="
