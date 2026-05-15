#!/usr/bin/env bash

echo "🧹 正在清理所有旧欢迎脚本..."

# ===== 1. 清 shell 层 =====
sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null
sed -i '/welcome.sh/d' ~/.profile 2>/dev/null

sed -i '/oci/d' /etc/profile 2>/dev/null
sed -i '/helper/d' /etc/profile 2>/dev/null
sed -i '/oci/d' ~/.bashrc 2>/dev/null
sed -i '/helper/d' ~/.bashrc 2>/dev/null
sed -i '/oci/d' ~/.profile 2>/dev/null
sed -i '/helper/d' ~/.profile 2>/dev/null

# ===== 2. 清 profile.d =====
rm -f /etc/profile.d/welcome.sh \
      /etc/profile.d/*oci* \
      /etc/profile.d/*helper* \
      2>/dev/null

# ===== 3. 清 MOTD =====
> /etc/motd
chmod -x /etc/update-motd.d/* 2>/dev/null
rm -f /etc/update-motd.d/*oci* /etc/update-motd.d/*helper* 2>/dev/null

echo "✅ 清理完成"

# ===== 4. 安装 welcome =====
echo "📦 安装你的欢迎面板..."

curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# ✅ 关键校验
if [ ! -s /etc/profile.d/welcome.sh ]; then
    echo "❌ welcome.sh 下载失败"
    exit 1
fi

chmod 755 /etc/profile.d/welcome.sh

echo "✅ 安装完成 🎉"
echo "👉 请重新登录 SSH"
