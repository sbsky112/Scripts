#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "请用 root 用户运行此脚本"
  exit 1
fi

echo "更新软件包列表..."
apt update

echo "安装qBittorrent-nox..."
apt install -y qbittorrent-nox

CONFIG_DIR="/root/.config/qBittorrent"
CONFIG_FILE="$CONFIG_DIR/qBittorrent.conf"
DOWNLOAD_DIR="/root/Downloads"

mkdir -p "$CONFIG_DIR"
mkdir -p "$DOWNLOAD_DIR"

echo "写入配置文件..."

if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" <<EOF
[Preferences]
EOF
fi

cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%s)" 2>/dev/null || true

function set_config() {
  local key="$1"
  local value="$2"
  if grep -q "^$key=" "$CONFIG_FILE"; then
    sed -i "s|^$key=.*|$key=$value|" "$CONFIG_FILE"
  else
    echo "$key=$value" >> "$CONFIG_FILE"
  fi
}

# 关闭防跨站功能
set_config "WebUI\CSRFProtection" "false"
# 设置默认下载目录
set_config "Downloads\SavePath" "$DOWNLOAD_DIR"

SERVICE_FILE="/etc/systemd/system/qbittorrent-nox.service"
echo "创建 systemd 服务文件 $SERVICE_FILE"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=qBittorrent-nox daemon
After=network.target

[Service]
User=root
ExecStart=/usr/bin/qbittorrent-nox
Restart=on-failure
RestartSec=10
KillMode=process
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable qbittorrent-nox
systemctl restart qbittorrent-nox

echo "等待 qBittorrent-nox 启动并生成 Web UI 密码..."
sleep 6

PASSWORD_LINE=$(journalctl -u qbittorrent-nox -n 50 --no-pager | grep "temporary password is provided for this session" | tail -1)

if [[ $PASSWORD_LINE =~ session:\ ([^[:space:]]+) ]]; then
  PASSWORD="${BASH_REMATCH[1]}"
  echo "qBittorrent-nox Web UI 随机密码是： $PASSWORD"
  echo "请使用 http://服务器IP:8080 访问，默认用户名 admin"
else
  echo "未能自动获取 Web UI 密码，请用以下命令查看日志："
  echo "journalctl -u qbittorrent-nox -n 50 --no-pager"
fi

echo "服务管理命令: systemctl {start|stop|restart|status} qbittorrent-nox"
