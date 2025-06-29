# qBittorrent 一键安装脚本（Ubuntu 24.04）

这是一个适用于 **Ubuntu 24.04** 系统的 `qBittorrent-nox` 一键安装脚本，基于命令行 Web UI，自动配置 systemd 服务，并设置默认登录信息与下载目录。

---

## ✅ 功能特点

- 安装最新版 `qbittorrent-nox`
- 配置为 systemd 服务，支持开机自启
- 默认账号密码：
  - 用户名：`admin`
  - 密码：``
- 默认监听端口：`8080`
- 关闭 CSRF 和点击劫持保护
- 默认下载目录：`/root/Downloads`
- 适合 VPS、NAS、服务器部署

---

## 📦 一键安装命令

请使用以下命令一键安装：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sbsky112/qBittorrent-AutoInstall/refs/heads/main/install_qbittorrent.sh)
```

---
## 🗑️ 一键卸载命令

请使用以下命令一键卸载：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sbsky112/qBittorrent-AutoInstall/refs/heads/main/uninstall_qbittorrent.sh)
```

---

## 👀 查看账号密码

请使用以下命令一键查看：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sbsky112/qBittorrent-AutoInstall/refs/heads/main/view_qbt_password.sh)
```

---
