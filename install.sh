#!/usr/bin/env bash

echo "🧹 清理旧欢迎脚本..."

# ==== 1. 清理 ====
sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null
sed -i '/oci/d' /etc/profile 2>/dev/null
sed -i '/helper/d' /etc/profile 2>/dev/null
sed -i '/oci/d' ~/.bashrc 2>/dev/null
sed -i '/helper/d' ~/.bashrc 2>/dev/null

rm -f /etc/profile.d/welcome.sh /etc/profile.d/*oci* /etc/profile.d/*helper* 2>/dev/null

echo "✅ 清理完成"

# ==== 2. 下载你的脚本 ====
echo "📦 下载 welcome 面板..."

curl -fsSL https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# 检查是否下载成功
if [ ! -f /etc/profile.d/welcome.sh ]; then
    echo "❌ 下载失败，请检查 GitHub 地址或网络"
    exit 1
fi

# ==== 3. 授权 ====
chmod 755 /etc/profile.d/welcome.sh

# ==== 4. 设置自动执行 ====
grep -q welcome.sh /etc/profile || echo "/etc/profile.d/welcome.sh" >> /etc/profile
grep -q welcome.sh ~/.bashrc || echo "/etc/profile.d/welcome.sh" >> ~/.bashrc

echo "✅ 安装完成 🎉"
echo "👉 请重新连接 SSH"
