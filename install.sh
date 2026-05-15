#!/usr/bin/env bash

echo "🧹 开始彻底清理旧欢迎脚本..."

# ===== 1. 清理 profile / bashrc 里的调用 =====
sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null

sed -i '/oci/d' /etc/profile 2>/dev/null
sed -i '/helper/d' /etc/profile 2>/dev/null
sed -i '/oci/d' ~/.bashrc 2>/dev/null
sed -i '/helper/d' ~/.bashrc 2>/dev/null

# ===== 2. 删除所有旧脚本 =====
rm -f /etc/profile.d/welcome.sh \
      /etc/profile.d/*oci* \
      /etc/profile.d/*helper* \
      /etc/profile.d/*login* 2>/dev/null

echo "✅ 清理完成"

# ===== 3. 下载你的 welcome =====
echo "📦 下载新欢迎面板..."

curl -fsSL https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# 检测下载
if [ ! -f /etc/profile.d/welcome.sh ]; then
    echo "❌ welcome.sh 下载失败"
    exit 1
fi

chmod 755 /etc/profile.d/welcome.sh

echo "✅ 安装完成"

# ===== 4. 设置唯一执行入口（核心）=====
echo "🔧 设置启动入口..."

echo 'source /etc/profile.d/welcome.sh' >> /etc/profile

echo "✅ 完成 🎉"
echo "👉 请重新登录 SSH 查看效果"
