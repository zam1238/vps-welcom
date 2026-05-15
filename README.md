# vps-welcom
vps 欢迎词
curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh && chmod 755 /etc/profile.d/welcome.sh

# ** 完整部署流程（标准版）**
# 下载脚本
curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh

# 授权
chmod 755 /etc/profile.d/welcome.sh

# 关闭默认欢迎
> /etc/motd
chmod -x /etc/update-motd.d/*

# 测试是否成功
exit 在连接
