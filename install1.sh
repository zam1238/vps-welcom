#!/usr/bin/env bash

echo "🚀 Zam Welcome Installer (Ultimate Edition)"

# ===== 检测系统 =====
if command -v apk >/dev/null 2>&1; then
    OS="alpine"
    echo "📦 检测到 Alpine"
    apk add bash >/dev/null 2>&1
else
    OS="linux"
fi

# ===== 防重复安装 =====
if [ -s /etc/profile.d/welcome.sh ]; then
    echo "✅ 已检测安装过，正在覆盖安装..."
fi

echo "🧹 清理旧欢迎..."

# ===== 1. shell 层 =====
sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null
sed -i '/welcome.sh/d' ~/.profile 2>/dev/null

sed -i '/oci/d' /etc/profile 2>/dev/null
sed -i '/helper/d' /etc/profile 2>/dev/null
sed -i '/oci/d' ~/.bashrc 2>/dev/null
sed -i '/helper/d' ~/.bashrc 2>/dev/null
sed -i '/oci/d' ~/.profile 2>/dev/null
sed -i '/helper/d' ~/.profile 2>/dev/null

# ===== 2. profile.d =====
rm -f /etc/profile.d/welcome.sh \
      /etc/profile.d/*oci* \
      /etc/profile.d/*helper* \
      2>/dev/null

# ===== 3. MOTD（核心）=====
> /etc/motd
chmod -x /etc/update-motd.d/* 2>/dev/null
rm -f /etc/update-motd.d/*oci* /etc/update-motd.d/*helper* 2>/dev/null

# ===== 4. PAM =====
sed -i '/pam_motd.so/d' /etc/pam.d/sshd 2>/dev/null
sed -i '/oci/d' /etc/pam.d/sshd 2>/dev/null
sed -i '/helper/d' /etc/pam.d/sshd 2>/dev/null

# ===== 5. SSH Banner =====
> /etc/issue 2>/dev/null
> /etc/issue.net 2>/dev/null

sed -i '/Banner/d' /etc/ssh/sshd_config 2>/dev/null
grep -q "Banner none" /etc/ssh/sshd_config || echo "Banner none" >> /etc/ssh/sshd_config

# ===== 6. cloud-init（安全清理）=====
rm -rf /var/lib/cloud/instance/scripts/*helper* 2>/dev/null
rm -rf /var/lib/cloud/scripts/per-*/*helper* 2>/dev/null

# ===== 7. 重启 SSH =====
systemctl restart ssh 2>/dev/null || service ssh restart

echo "✅ 清理完成"

# ===== 8. 下载 welcome =====
echo "📦 安装欢迎面板..."

curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# ===== 校验 =====
if [ ! -s /etc/profile.d/welcome.sh ]; then
    echo "❌ 下载失败（网络或GitHub问题）"
    exit 1
fi

chmod 755 /etc/profile.d/welcome.sh

# ===== 9. Alpine 兼容（关键）=====
if [ "$OS" = "alpine" ]; then
    grep -q welcome.sh ~/.bashrc || echo 'bash /etc/profile.d/welcome.sh' >> ~/.bashrc
fi

echo ""
echo "✅ 安装完成 🎉"
echo "👉 请重新连接 SSH"
