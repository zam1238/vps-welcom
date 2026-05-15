#!/usr/bin/env bash#!/usr/binelcome.sh

chmod 755 /etc/profile.d/welcome.sh

# ==== 3. 设置自动执行 ====

grep -q welcome.sh /etc/profile || echo "bash /etc/profile.d/welcome.sh" >> /etc/profile

grep -q welcome.sh ~/.bashrc || echo "bash /etc/profile.d/welcome.sh" >> ~/.bashrc

echo "✅ 安装完成 🎉"
echo "👉 请重新连接 SSH 查看效果"

echo "✅ 开始清理旧欢迎脚本..."

# ==== 1. 清理所有旧欢迎 ====

sed -i '/welcome.sh/d' /etc/profile 2>/dev/null
sed -i '/welcome.sh/d' ~/.bashrc 2>/dev/null

sed -i '/oci/d' /etc/profile 2>/dev/null
sed -i '/helper/d' /etc/profile 2>/dev/null
sed -i '/oci/d' ~/.bashrc 2>/dev/null
sed -i '/helper/d' ~/.bashrc 2>/dev/null

rm -f /etc/profile.d/welcome.sh /etc/profile.d/*oci* /etc/profile.d/*helper* 2>/dev/null

echo "✅ 清理完成"

# ==== 2. 下载你的脚本 ====

echo "🚀 安装新欢迎面板..."

