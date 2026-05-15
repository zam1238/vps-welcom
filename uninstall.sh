#!/usr/bin/env bash

echo "══════════════════════════════════════════════"
echo "🗑️  Zam Welcome Uninstaller"
echo "══════════════════════════════════════════════"

echo "🧹 正在清理欢迎脚本环境..."

# ===== 1. 删入口 =====
echo "→ 清理启动入口..."
sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null
sed -i '/welcome.sh/d' ~/.profile 2>/dev/null

# ===== 2. 删脚本 =====
echo "→ 删除 welcome.sh..."
rm -f /etc/profile.d/welcome.sh 2>/dev/null

# ===== 3. 清 MOTD =====
echo "→ 清理 MOTD..."
> /etc/motd
chmod -x /etc/update-motd.d/* 2>/dev/null

# ===== 4. 清 SSH Banner =====
echo "→ 清理 SSH Banner..."
> /etc/issue
> /etc/issue.net
sed -i '/Banner/d' /etc/ssh/sshd_config 2>/dev/null

# ===== 5. 重启 SSH =====
echo "→ 重启 SSH 服务..."
systemctl restart ssh 2>/dev/null || service ssh restart

echo "✅ 卸载完成！"
echo "👉 请重新登录 SSH 查看效果"
echo "══════════════════════════════════════════════"
