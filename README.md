# 🌐 VPS Welcome Panel
## 🚀 一键安装

##  Alpine 一键版
```
bash <(curl -fsSL https://raw.githubusercontent.com/zam1238/vps-welcom/main/install1.sh)
```


## Debian 一键版

```
bash <(curl -fsSL https://raw.githubusercontent.com/zam1238/vps-welcom/main/install.sh)
```

##  卸载

```
bash <(curl -fsSL https://raw.githubusercontent.com/zam1238/vps-welcom/main/uninstall.sh)
```

一个轻量级 SSH 登录欢迎面板，支持：

- 🌍 中文地区自动识别（带国旗）
- 🌐 ISP / ASN 自动检测
- 📡 网络线路识别（CN2 / 4837 / 9929）
- 🌍 回程路径分析
- 📶 延迟 / Google 测速
- 🐳 Docker 容器状态

适用于多服务器统一部署。

修改welcome.sh 里面输出对应的文字 比如zam-甲骨文可以改成大聪明 自己看着舒服点
文件路径/etc/profile.d/welcome.sh 也可以在上面改
全程AI写的 我自己用的方便
