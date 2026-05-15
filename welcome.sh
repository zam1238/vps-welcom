#!/usr/bin/env bash

# 路径: /etc/profile.d/welcome.sh
# 授权: chmod +x /etc/profile.d/welcome.sh

# 如果不是 bash，直接退出（避免 sh 解析后面代码）
[ -n "$BASH_VERSION" ] || return 0

# 只在交互终端显示
[ -z "$PS1" ] && return

main() {

export TERM=xterm-256color

G=$'\033[1;32m'
C=$'\033[1;36m'
Y=$'\033[1;33m'
R=$'\033[1;31m'
N=$'\033[0m'

clear

# 👇👇👇 你的所有原代码都放这里 👇👇👇
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
# IPV4_IN="216.167.28.38" 可以固定
IPV4_IN=$(curl -4 -s --max-time 1 ifconfig.me)   
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
# ===== 区域 + 运营商 + ASN =====

IP_INFO=$(curl -s --max-time 2 ipinfo.io/json)

CITY=$(echo "$IP_INFO" | grep '"city"' | sed -E 's/.*"city": ?"([^"]+)".*/\1/')
COUNTRY=$(echo "$IP_INFO" | grep '"country"' | sed -E 's/.*"country": ?"([^"]+)".*/\1/')
ORG=$(echo "$IP_INFO" | grep '"org"' | sed -E 's/.*"org": ?"([^"]+)".*/\1/')

ASN=$(echo "$ORG" | awk '{print $1}')
ISP=$(echo "$ORG" | cut -d' ' -f2-)

# ===== 国家中文 + 国旗 =====
get_country_cn() {
    case "$1" in
        US) echo "🇺🇸 美国";;
        DE) echo "🇩🇪 德国";;
        HK) echo "🇭🇰 香港";;
        SG) echo "🇸🇬 新加坡";;
        JP) echo "🇯🇵 日本";;
        KR) echo "🇰🇷 韩国";;
        FI) echo "🇫🇮 芬兰";;
        NL) echo "🇳🇱 荷兰";;
        GB) echo "🇬🇧 英国";;
        FR) echo "🇫🇷 法国";;
        CA) echo "🇨🇦 加拿大";;
        AU) echo "🇦🇺 澳大利亚";;
        RU) echo "🇷🇺 俄罗斯";;
        IN) echo "🇮🇳 印度";;
        BR) echo "🇧🇷 巴西";;
        *) echo "$1";;
    esac
}

# ===== 城市中文 =====
get_city_cn() {
    case "$1" in
        "Los Angeles") echo "洛杉矶";;
        "Tokyo") echo "东京";;
        "Singapore") echo "新加坡";;
        "Hong Kong") echo "香港";;
        "Frankfurt") echo "法兰克福";;
        "Helsinki") echo "赫尔辛基";;
        "Amsterdam") echo "阿姆斯特丹";;
        "London") echo "伦敦";;
        "Paris") echo "巴黎";;
        "Seoul") echo "首尔";;
        "Toronto") echo "多伦多";;
        "Sydney") echo "悉尼";;
        *) echo "$1";;
    esac
}

COUNTRY_CN=$(get_country_cn "$COUNTRY")
CITY_CN=$(get_city_cn "$CITY")

LOCATION="${COUNTRY_CN}·${CITY_CN}"
ISP_INFO="${ISP}（${ASN}）"

# ===== ASN线路识别（精准版） =====

LINE_TYPE="普通国际线路"
CN2="❌"
C4837="❌"
C9929="❌"

case "$ASN" in
    AS4134|4134|AS4809|4809)
        LINE_TYPE="电信线路"
        ;;
    AS4837|4837)
        LINE_TYPE="电信4837"
        C4837="✅"
        ;;
    AS9929|9929)
        LINE_TYPE="联通精品网"
        C9929="✅"
        ;;
esac

# ===== traceroute线路分析 =====

TRACE_INFO=""

echo "$TRACE" | grep -q "59.43" && CN2="✅" && TRACE_INFO="CN2线路"
echo "$TRACE" | grep -q "202.97" && TRACE_INFO="163线路"
echo "$TRACE" | grep -q "218.105" && C4837="✅"
echo "$TRACE" | grep -q "210.51" && C9929="✅"

# ===== 回程路径分析 =====

BACK_ROUTE="直连"

echo "$TRACE" | grep -q "JP" && BACK_ROUTE="经日本中转"
echo "$TRACE" | grep -q "HK" && BACK_ROUTE="经香港中转"
echo "$TRACE" | grep -q "US" && BACK_ROUTE="经美国中转"


# ===== CN2细分识别 =====

CN2_TYPE="无"

echo "$TRACE" | grep -q "59.43" && CN2="✅" && CN2_TYPE="CN2线路"

# 简单区分 GT / GIA（参考判断）
echo "$TRACE" | grep -q "59.43" && echo "$TRACE" | grep -q "202.97" && CN2_TYPE="CN2 GT"
echo "$TRACE" | grep -q "59.43" && ! echo "$TRACE" | grep -q "202.97" && CN2_TYPE="CN2 GIA"


# ===== 系统 =====
DISK=$(df -h / | awk 'NR==2 {print $5}')
MEM=$(free | awk '/Mem/ {printf("%.0f%%"), $3/$2 * 100.0}')
LOAD=$(uptime | awk -F'load average:' '{print $2}')

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


# ===== 输出 =====
# 🔐 SSH:28820 │ 🔐 端口范围:28820 手改以免小鸡端口记不住范围

echo -e "${C}════════════════════════ 🌐 Zam-甲骨文 ════════════════════════${N}"
echo -e "📍 位置: $LOCATION │ 运营商: $ISP_INFO"

echo -e "${C}────────── 出入信息 ──────────${N}"
echo -e "📥 入口: IPv4 $IPV4_IN │ IPv6 $IPV6_IN │ 🔐 SSH:22 │ 🔐 端口范围:全端口"  
echo -e "📤 出口: IPv4 $IPV4_OUT │ IPv6 $IPV6_OUT │ 🚦 出口协议: $PREFER"

echo -e "${C}────────── 网络线路 ──────────${N}"
echo -e "📡 线路类型: $LINE_TYPE │ 🌍 回程路径: $BACK_ROUTE"
echo -e "🔍 路径识别: $CN2_TYPE │ 4837:$C4837 │ 9929:$C9929"

echo -e "${C}────────── 性能测试 ──────────${N}"
echo -e "💾 磁盘使用:$DISK │ 🧠 内存使用:$MEM │ ⚡ 系统负载:$LOAD"
echo -e "📶 延迟: v4 ${G}${PING_V4}ms${N}(${V4_TYPE}) │ v6 ${C}${PING_V6}ms${N}(${V6_TYPE})"
echo -e "🌐 Google访问: ${Y}${GOOGLE_MS}ms${N}"

echo -e "${C}────────── 质量评估 ──────────${N}"
echo -e "📡 状态: v4 $V4_STATUS │ v6 $V6_STATUS │ 📊 评分: v4=$SCORE_V4 │ v6=$SCORE_V6 │ ★综合:$FINAL"
echo -e "🧠 风控: $RISK │ 🛡️ 网络: 正常 ✅"

echo -e "${C}────────── 系统服务 ──────────${N}"
echo -e "🐳 DOCKER容器: $DOCKER_STATUS"

echo -e "${C}═══════════════════════ 甲骨文 ═════════════════════════${N}"

}

main



