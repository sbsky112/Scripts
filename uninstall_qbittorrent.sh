#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "请用 root 用户运行此脚本"
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/qbittorrent-nox.service"
CONFIG_DIR="/root/.config/qBittorrent"
DOWNLOAD_DIR="/root/Downloads"

echo "停止并禁用 qBittorrent-nox 服务..."
systemctl stop qbittorrent-nox 2>/dev/null || true
systemctl disable qbittorrent-nox 2>/dev/null || true

echo "删除 systemd 服务文件..."
if [ -f "$SERVICE_FILE" ]; then
  rm -f "$SERVICE_FILE"
  systemctl daemon-reload
fi

echo "卸载 qBittorrent-nox 软件包..."
apt remove -y qbittorrent-nox
apt autoremove -y

echo "删除配置文件和下载目录..."
rm -rf "$CONFIG_DIR"
rm -rf "$DOWNLOAD_DIR"

echo "qBittorrent-nox 已成功卸载，相关文件已删除。"
