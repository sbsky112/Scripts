#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "请用 root 用户运行"
  exit 1
fi

apt update
apt install -y qbittorrent-nox expect

mkdir -p /root/Downloads
chown root:root /root/Downloads

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

rm -rf /root/.config/qBittorrent

expect -c "
spawn qbittorrent-nox
expect \"Do you want to start the Web UI? (y/n)\"
send \"y\r\"
expect \"Set Web UI username:\"
send \"admin\r\"
expect \"Set Web UI password:\"
send \"qwe123456\r\"
expect \"Confirm Web UI password:\"
send \"qwe123456\r\"
expect eof
"

pkill qbittorrent-nox || true

systemctl start qbittorrent

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "======================================="
echo "qBittorrent 安装并配置完成！"
echo "Web UI 地址: http://$IP:8080"
echo "用户名：admin"
echo "密码：qwe123456"
echo "下载目录：/root/Downloads"
echo "======================================="
