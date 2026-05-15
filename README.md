# 🌐 VPS Welcome Panel
## 🚀 一键安装

```bash
curl -L https://raw.githubusercontent.com/zam1238/vps-welcom/main/welcome.sh -o /etc/profile.d/welcome.sh && chmod 755 /etc/profile.d/welcome.sh && > /etc/motd && chmod -x /etc/update-motd.d/* && sed -i '/pam_motd.so/d' /etc/pam.d/sshd

一个轻量级 SSH 登录欢迎面板，支持：

- 🌍 中文地区自动识别（带国旗）
- 🌐 ISP / ASN 自动检测
- 📡 网络线路识别（CN2 / 4837 / 9929）
- 🌍 回程路径分析
- 📶 延迟 / Google 测速
- 🎬 流媒体解锁检测（Netflix / Disney+ / TikTok）
- 🤖 ChatGPT API 可用性检测
- 🐳 Docker 容器状态

适用于多服务器统一部署。
