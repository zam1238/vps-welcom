#!/bin/bash
# 路径：/etc/profile.d/welcome.sh
# 授权：chmod +x /etc/profile.d/welcome.sh
# 开启你的脚本：chmod 755 /etc/profile.d/welcome.sh
#              source /etc/profile
# 关闭系统欢迎词：> /etc/motd
#               chmod -x /etc/update-motd.d/*
#

# 或者直接替换：/etc/motd  里面的内容 这样最简单

export TERM=xterm-256color

G="\033[1;32m"
C="\033[1;36m"
Y="\033[1;33m"
R="\033[1;31m"
N="\033[0m"

clear

# ===== ICMP延迟检测 =====
detect_ping() {
    local target=$1
    local result

    result=$(ping -c 1 -W 1 $target 2>/dev/null | \
        awk -F'time=' '/time=/{print $2}' | awk '{print int($1)}')

    echo "$result"
}

# ===== HTTP延迟检测 =====
detect_http() {
    local version=$1
    local url
    local result

    if [ "$version" = "6" ]; then
        url="https://[2606:4700:4700::1111]"
    else
        url="https://1.1.1.1"
    fi

    result=$(curl -${version} -o /dev/null -s -w "%{time_total}" --max-time 2 $url)

    echo "$result"
}


# ===== 入站 =====
IPV4_IN="216.167.28.38"
IPV6_IN=$(curl -6 -s --max-time 1 ifconfig.me 2>/dev/null)

# ===== 出站 =====
IPV4_OUT=$(curl -4 -s --max-time 1 ifconfig.me)
IPV6_OUT=$(curl -6 -s --max-time 1 ifconfig.me 2>/dev/null)

# ===== 出口判断 =====
CUR_IP=$(curl -s --max-time 1 ifconfig.me)
if [[ "$CUR_IP" == *":"* ]]; then
    PREFER="${G}IPv6优先✅${N}"
else
    PREFER="${Y}IPv4优先${N}"
fi

# ===== 地区 =====
CITY=$(curl -s --max-time 1 ipinfo.io/city)
COUNTRY=$(curl -s --max-time 1 ipinfo.io/country)

case "$COUNTRY" in
    US) COUNTRY_CN="美国";;
    DE) COUNTRY_CN="德国";;
    HK) COUNTRY_CN="香港";;
    SG) COUNTRY_CN="新加坡";;
    JP) COUNTRY_CN="日本";;
    *) COUNTRY_CN="$COUNTRY";;
esac

case "$CITY" in
    "Los Angeles") CITY_CN="洛杉矶";;
    "Tokyo") CITY_CN="东京";;
    "Singapore") CITY_CN="新加坡";;
    "Hong Kong") CITY_CN="香港";;
    "Frankfurt") CITY_CN="法兰克福";;
    *) CITY_CN="$CITY";;
esac

LOCATION="${COUNTRY_CN}·${CITY_CN}"

# ===== 系统 =====
DISK=$(df -h / | awk 'NR==2 {print $5}')
MEM=$(free | awk '/Mem/ {printf("%.0f%%"), $3/$2 * 100.0}')
LOAD=$(uptime | awk -F'load average:' '{print $2}')

# ===== 延迟智能判断版（最终稳定版）=====# ===== 延 V6_STATUS="${G}真实线路${N}"
# ===== 延迟智能判断版（最终稳定版）=====

# ===== v4 =====
PING_V4_ICMP=$(detect_ping 8.8.8.8)
PING_V4_HTTP=$(detect_http 4)

[ -z "$PING_V4_HTTP" ] && PING_V4_HTTP=0
PING_V4_HTTP=$(awk "BEGIN {printf \"%.0f\", $PING_V4_HTTP*1000}")

if [ -n "$PING_V4_ICMP" ] && [ "$PING_V4_ICMP" != "0" ]; then
    PING_V4=$PING_V4_ICMP
    V4_TYPE="ICMP✅"
    V4_STATUS="${G}真实线路${N}"
else
    PING_V4=$PING_V4_HTTP
    V4_TYPE="HTTP⚠️"
    V4_STATUS="${Y}ICMP受限${N}"
fi


# ===== v6 =====
PING_V6_ICMP=$(detect_ping 2001:4860:4860::8888)
PING_V6_HTTP=$(detect_http 6)

[ -z "$PING_V6_HTTP" ] && PING_V6_HTTP=0
PING_V6_HTTP=$(awk "BEGIN {printf \"%.0f\", $PING_V6_HTTP*1000}")

if [ -n "$PING_V6_ICMP" ] && [ "$PING_V6_ICMP" != "0" ]; then
    PING_V6=$PING_V6_ICMP
    V6_TYPE="ICMP✅"
    V6_STATUS="${G}真实线路${N}"
else
    PING_V6=$PING_V6_HTTP
    V6_TYPE="HTTP⚠️"
    V6_STATUS="${Y}ICMP受限${N}"
fi

# ===== 防空 =====
[ -z "$PING_V4" ] && PING_V4=0
[ -z "$PING_V6" ] && PING_V6=0

P4=${PING_V4%.*}
P6=${PING_V6%.*}

# ===== Google速度 =====
GOOGLE_TIME=$(curl -o /dev/null -s -w "%{time_total}" --max-time 2 https://www.google.com)
GOOGLE_MS=$(awk "BEGIN {printf \"%.0f\", $GOOGLE_TIME*1000}")

# ===== 评分 =====
score() {
    local v=$1
    if [ "$v" -eq 0 ]; then echo "${R}X${N}"
    elif [ "$v" -lt 30 ]; then echo "${G}A+${N}"
    elif [ "$v" -lt 60 ]; then echo "${G}A${N}"
    elif [ "$v" -lt 120 ]; then echo "${Y}B${N}"
    else echo "${R}C${N}"
    fi
}

SCORE_V4=$(score $P4)
SCORE_V6=$(score $P6)

# ===== 综合评分 =====
if [ "$P4" -lt 30 ] && [ "$GOOGLE_MS" -lt 300 ]; then
    FINAL="${G}A+${N}"
elif [ "$P4" -lt 60 ]; then
    FINAL="${G}A${N}"
elif [ "$P4" -lt 120 ]; then
    FINAL="${Y}B${N}"
else
    FINAL="${R}C${N}"
fi

# ===== 风控 =====
if [ "$GOOGLE_MS" -lt 300 ]; then
    RISK="${G}🟢干净${N}"
elif [ "$GOOGLE_MS" -gt 800 ]; then
    RISK="${R}🔴可疑${N}"
else
    RISK="${Y}🟡一般${N}"
fi

# ===== 解锁 =====
YT=$(curl -s --max-time 2 https://www.youtube.com | grep youtube >/dev/null && echo 1 || echo 0)
NF=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 https://www.netflix.com/title/80018499)
GPT=$(curl -s --max-time 2 https://chat.openai.com | grep OpenAI >/dev/null && echo 1 || echo 0)

[ "$YT" = "1" ] && YT_ICON="${G}✅${N}" || YT_ICON="${R}❌${N}"

if [ "$NF" = "200" ]; then
    NF_ICON="${G}✅${N}"
elif [ "$NF" = "403" ]; then
    NF_ICON="${Y}🟡${N}"
else
    NF_ICON="${R}❌${N}"
fi

[ "$GPT" = "1" ] && GPT_ICON="${G}✅${N}" || GPT_ICON="${R}❌${N}"

# ===== Docker =====
DOCKER_LIST=$(docker ps -a --format "{{.Names}} {{.State}}" 2>/dev/null)

DOCKER_STATUS=""
COUNT=0

while read -r name state
do
    [ -z "$name" ] && continue

    if [ "$state" = "running" ]; then
        STATUS="${G}🟢${N}"
    else
        STATUS="${R}🔴${N}"
    fi

    DOCKER_STATUS="$DOCKER_STATUS$name $STATUS  "

    COUNT=$((COUNT+1))
    [ $COUNT -ge 4 ] && break

done <<< "$DOCKER_LIST"

# ===== 输出 =====
# 🔐 SSH:28820 │ 🔐 端口范围:28820 手改以免小鸡端口记不住范围

echo -e "${C}══════════ 🌐 Zam-F佬 美家宽══════════${N}"

echo -e "📥 入口: IPv4 $IPV4_IN │ IPv6 $IPV6_IN │ 🔐 SSH:28820 │ 🔐 端口范围:28820"  
echo -e "📤 出口: IPv4 $IPV4_OUT │ IPv6 $IPV6_OUT │ 📍 $LOCATION"
echo -e "🚦 出口协议: $PREFER"

echo -e "💾 磁盘使用:$DISK │ 🧠 内存使用:$MEM │ ⚡ 系统负载:$LOAD"

echo -e "📶 延迟: v4 ${G}${PING_V4}ms${N}(${V4_TYPE}) │ v6 ${C}${PING_V6}ms${N}(${V6_TYPE})"
echo -e "🌐 Google访问: ${Y}${GOOGLE_MS}ms${N}"

echo -e "📡 状态: v4 $V4_STATUS │ v6 $V6_STATUS │ 📊 评分: v4=$SCORE_V4 │ v6=$SCORE_V6 │ ★综合:$FINAL"

echo -e "🧠 风控: $RISK │ 🛡️ 网络: 正常 ✅"

echo -e "🎬 解锁情况: YouTube $YT_ICON │ Netflix $NF_ICON │ ChatGPT $GPT_ICON │ Google ✅"

echo -e "🐳 容器: $DOCKER_STATUS"

echo -e "${C}══════════════════════════════════════${N}"
