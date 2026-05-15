#!/usr/bin/env bash

echo "🚀 Zam Welcome Installer (Ultimate Edition)"

# ===== 防重复入口（最关键）=====
echo "🧹 修复重复执行问题..."

sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null
sed -i '/welcome.sh/d' ~/.profile 2>/dev/null

# ===== 清理旧环境 =====
echo "🧹 清理旧欢迎..."

# profile.d
rm -f /etc/profile.d/welcome.sh \
      /etc/profile.d/*oci* \
      /etc/profile.d/*helper* \
      2>/dev/null

# MOTD
> /etc/motd
chmod -x /etc/update-motd.d/* 2>/dev/null
rm -f /etc/update-motd.d/*oci* /etc/update-motd.d/*helper* 2>/dev/null

# PAM
sed -i '/pam_motd.so/d' /etc/pam.d/sshd 2>/dev/null
sed -i '/oci/d' /etc/pam.d/sshd 2>/dev/null
sed -i '/helper/d' /etc/pam.d/sshd 2>/dev/null

# SSH Banner
> /etc/issue 2>/dev/null
> /etc/issue.net 2>/dev/null
sed -i '/Banner/d' /etc/ssh/sshd_config 2>/dev/null
grep -q "Banner none" /etc/ssh/sshd_config || echo "Banner none" >> /etc/ssh/sshd_config

# cloud-init（安全）
rm -rf /var/lib/cloud/instance/scripts/*helper* 2>/dev/null
rm -rf /var/lib/cloud/scripts/per-*/*helper* 2>/dev/null

# 重启 ssh
systemctl restart ssh 2>/dev/null || service ssh restart

echo "✅ 清理完成"

# ===== 安装 welcome =====
echo "📦 安装你的欢迎面板..."

curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# ✅ 校验（关键）
if [ ! -s /etc/profile.d/welcome.sh ]; then
    echo "❌ welcome.sh 下载失败"
    exit 1
fi

chmod 755 /etc/profile.d/welcome.sh

echo ""
echo "✅ 安装完成 🎉"
echo "✅ 已自动防止重复执行"
echo "👉 请重新登录 SSH"
