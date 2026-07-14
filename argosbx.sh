#!/bin/sh
export LANG=en_US.UTF-8
MIERU_VERSION=v3.34.0
MIERU_RELEASE_TAG=mieru-core-v3.34.0
ARGOSBX_DEFAULT_REPO=${GITHUB_REPOSITORY:-yonggekkk/argosbx}
[ -z "${vlpt+x}" ] || vlp=yes
[ -z "${vmpt+x}" ] || { vmp=yes; vmag=yes; }
[ -z "${vwpt+x}" ] || { vwp=yes; vmag=yes; }
[ -z "${hypt+x}" ] || hyp=yes
[ -z "${tupt+x}" ] || tup=yes
[ -z "${xhpt+x}" ] || xhp=yes
[ -z "${vxpt+x}" ] || vxp=yes
[ -z "${anpt+x}" ] || anp=yes
[ -z "${sspt+x}" ] || ssp=yes
[ -z "${arpt+x}" ] || arp=yes
[ -z "${sopt+x}" ] || sop=yes
[ -z "${warp+x}" ] || wap=yes
[ -z "${mitpt+x}" ] || mit=yes
[ -z "${miupt+x}" ] || miu=yes

is_exe_running(){
target=$(readlink -f "$1" 2>/dev/null || printf '%s' "$1")
for exe in /proc/[0-9]*/exe; do
[ -L "$exe" ] || continue
[ "$(readlink -f "$exe" 2>/dev/null)" = "$target" ] && return 0
done
return 1
}
kill_exe(){
target=$(readlink -f "$1" 2>/dev/null || printf '%s' "$1")
signal=${2:-TERM}
for exe in /proc/[0-9]*/exe; do
[ -L "$exe" ] || continue
if [ "$(readlink -f "$exe" 2>/dev/null)" = "$target" ]; then
kill -s "$signal" "$(basename "$(dirname "$exe")")" 2>/dev/null || true
fi
done
}
has_argosbx_install(){
[ -f "$HOME/agsbx/xr.json" ] || [ -f "$HOME/agsbx/sb.json" ] || [ -f "$HOME/agsbx/mita.json" ]
}
legacy_selected(){
[ "$vwp" = yes ] || [ "$sop" = yes ] || [ "$vxp" = yes ] || [ "$ssp" = yes ] || [ "$vlp" = yes ] || [ "$vmp" = yes ] || [ "$hyp" = yes ] || [ "$tup" = yes ] || [ "$xhp" = yes ] || [ "$anp" = yes ] || [ "$arp" = yes ]
}
mieru_selected(){
[ "$mit" = yes ] || [ "$miu" = yes ]
}
any_protocol_selected(){
legacy_selected || mieru_selected
}

clean_agsbx_bashrc(){
[ -f "$HOME/.bashrc" ] || return 0
argosbx_bashrc_tmp="$HOME/.bashrc.argosbx.$$"
if awk '
function reset_block() {
  block = ""
  count = 0
}
function keep_block( i) {
  for (i = 1; i <= count; i++) print saved[i]
  reset_block()
}
block != "" {
  saved[++count] = $0
  if ((block == "path" && $0 == "# <<< ARGOSBX PATH <<<") ||
      (block == "healthcheck" && $0 == "# <<< ARGOSBX HEALTHCHECK <<<") ||
      (block == "legacy" && $0 ~ /^[[:space:]]*unset -f argosbx_healthcheck[[:space:]]*$/)) {
    reset_block()
  }
  next
}
$0 == "# >>> ARGOSBX PATH >>>" {
  block = "path"
  count = 1
  saved[count] = $0
  next
}
$0 == "# >>> ARGOSBX HEALTHCHECK >>>" {
  block = "healthcheck"
  count = 1
  saved[count] = $0
  next
}
$0 ~ /^[[:space:]]*argosbx_healthcheck[[:space:]]*\(\)[[:space:]]*\{[[:space:]]*$/ {
  block = "legacy"
  count = 1
  saved[count] = $0
  next
}
index($0, "pgrep -f") && index($0, "$HOME/bin/agsbx") { next }
$0 ~ /^[[:space:]]*export PATH="\$HOME\/bin:\$PATH"[[:space:]]*$/ { next }
{ print }
END {
  if (block != "") keep_block()
}
' "$HOME/.bashrc" > "$argosbx_bashrc_tmp"; then
cat "$argosbx_bashrc_tmp" > "$HOME/.bashrc"
fi
rm -f "$argosbx_bashrc_tmp"
}
ensure_agsbx_path(){
argosbx_bashrc_tmp="$HOME/.bashrc.argosbx-path.$$"
printf '%s\n' \
'# >>> ARGOSBX PATH >>>' \
'export PATH="$HOME/bin:$PATH"' \
'# <<< ARGOSBX PATH <<<' > "$argosbx_bashrc_tmp" &&
cat "$HOME/.bashrc" >> "$argosbx_bashrc_tmp" &&
cat "$argosbx_bashrc_tmp" > "$HOME/.bashrc"
rm -f "$argosbx_bashrc_tmp"
}

case "${argo:-}" in
mitpt|miupt|mieru|mita)
echo "错误：Mieru 使用原生 TCP/UDP，不能选作 Argo/CDN 协议" >&2
exit 1
;;
esac

if has_argosbx_install; then
if [ "$1" = "rep" ]; then
any_protocol_selected || { echo "提示：rep重置协议时，请在脚本前至少设置一个协议变量哦，再见！💣"; exit; }
fi
else
[ "$1" = "del" ] || any_protocol_selected || { echo "提示：未安装argosbx脚本，请在脚本前至少设置一个协议变量哦，再见！💣"; exit; }
fi
export uuid=${uuid:-''}
export port_vl_re=${vlpt:-''}
export port_vm_ws=${vmpt:-''}
export port_vw=${vwpt:-''}
export port_hy2=${hypt:-''}
export port_tu=${tupt:-''}
export port_xh=${xhpt:-''}
export port_vx=${vxpt:-''}
export port_an=${anpt:-''}
export port_ar=${arpt:-''}
export port_ss=${sspt:-''}
export port_so=${sopt:-''}
export port_mi_tcp=${mitpt:-''}
export port_mi_udp=${miupt:-''}
export miuser=${miuser:-''}
export mipass=${mipass:-''}
export ym_vl_re=${reym:-''}
export cdnym=${cdnym:-''}
export argo=${argo:-''}
export ARGO_DOMAIN=${agn:-''}
export ARGO_AUTH=${agk:-''}
export ippz=${ippz:-''}
export warp=${warp:-''}
export name=${name:-''}
export oap=${oap:-''}
v46url="https://icanhazip.com"
if [ -z "${ARGOSBX_ASSET_REPO:-}" ] && [ -s "$HOME/agsbx/asset_repo" ]; then
ARGOSBX_ASSET_REPO=$(cat "$HOME/agsbx/asset_repo" 2>/dev/null)
fi
ARGOSBX_ASSET_REPO=${ARGOSBX_ASSET_REPO:-$ARGOSBX_DEFAULT_REPO}
agsbxurl="https://raw.githubusercontent.com/$ARGOSBX_ASSET_REPO/main/argosbx.sh"
MIERU_RELEASE_BASE="https://github.com/$ARGOSBX_ASSET_REPO/releases/download/$MIERU_RELEASE_TAG"
showmode(){
echo "Argosbx脚本一键SSH命令生器在线网址：https://yonggekkk.github.io/argosbx/"
echo "主脚本：ARGOSBX_ASSET_REPO=$ARGOSBX_ASSET_REPO bash <(curl -Ls $agsbxurl) 或 ARGOSBX_ASSET_REPO=$ARGOSBX_ASSET_REPO bash <(wget -qO- $agsbxurl)"
echo "显示节点信息命令：agsbx list 【或者】 主脚本 list"
echo "重置变量组命令：自定义各种协议变量组 agsbx rep 【或者】 自定义各种协议变量组 主脚本 rep"
echo "更新脚本命令：原已安装的自定义各种协议变量组 主脚本 rep"
echo "更新Xray、Sing-box或Mieru内核命令：agsbx upx、ups或upm 【或者】 主脚本 upx、ups或upm"
echo "重启脚本命令：agsbx res 【或者】 主脚本 res"
echo "卸载脚本命令：agsbx del 【或者】 主脚本 del"
echo "双栈VPS显示IPv4/IPv6节点配置命令：ippz=4或6 agsbx list 【或者】 ippz=4或6 主脚本 list"
echo "---------------------------------------------------------"
echo
}
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "甬哥Github项目 ：github.com/yonggekkk"
echo "甬哥Blogger博客 ：ygkkk.blogspot.com"
echo "甬哥YouTube频道 ：www.youtube.com/@ygkkk"
echo "Argosbx一键无交互小钢炮脚本💣"
echo "当前版本：V26.5.10"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
hostname=$(uname -a | awk '{print $2}')
op=$(cat /etc/redhat-release 2>/dev/null || cat /etc/os-release 2>/dev/null | grep -i pretty_name | cut -d \" -f2)
[ -z "$(systemd-detect-virt 2>/dev/null)" ] && vi=$(virt-what 2>/dev/null) || vi=$(systemd-detect-virt 2>/dev/null)
case $(uname -m) in
arm64|aarch64) cpu=arm64;;
amd64|x86_64) cpu=amd64;;
*) echo "目前脚本不支持$(uname -m)架构" && exit
esac
if [ "$1" != "del" ]; then
mkdir -p "$HOME/agsbx"
chmod 0700 "$HOME/agsbx" 2>/dev/null || true
printf '%s\n' "$ARGOSBX_ASSET_REPO" > "$HOME/agsbx/asset_repo"
chmod 0600 "$HOME/agsbx/asset_repo" 2>/dev/null || true
if [ ! -f sbx_update ]; then
echo "执行必要的脚本依赖中，请稍等10秒……"
if command -v apk >/dev/null 2>&1; then
apk update >/dev/null 2>&1 && apk add --no-cache bash busybox-extras ca-certificates coreutils curl gcompat iproute2 libc6-compat iptables openssl wget >/dev/null 2>&1
elif command -v apt >/dev/null 2>&1; then
export DEBIAN_FRONTEND=noninteractive
printf 'iptables-persistent iptables-persistent/autosave_v4 boolean true\niptables-persistent iptables-persistent/autosave_v6 boolean true\n' | debconf-set-selections
apt update >/dev/null 2>&1 && apt install -y busybox ca-certificates coreutils curl iproute2 util-linux wget iptables iptables-persistent cron openssl >/dev/null 2>&1
fi
touch sbx_update
fi
fi
v4v6(){
v4=$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 --tries=2 -qO- "$v46url" 2>/dev/null) )
v6=$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 --tries=2 -qO- "$v46url" 2>/dev/null) )
v4dq=$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k https://myip.ipip.net/ | awk -F'来自于：' '{print $2}' 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 --tries=2 -qO- https://myip.ipip.net/ | awk -F'来自于：' '{print $2}' 2>/dev/null) )
v6dq=$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k https://ip.fm | sed -n 's/.*Location: //p' 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 --tries=2 -qO- https://ip.fm | grep '<span class="has-text-grey-light">Location:' | tail -n1 | sed -E 's/.*>Location: <\/span>([^<]+)<.*/\1/' 2>/dev/null) )
}
warpsx(){
warpurl=$( (command -v curl >/dev/null 2>&1 && curl -sm5 -k https://warp.xijp.eu.org 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget --tries=2 -qO- https://warp.xijp.eu.org 2>/dev/null) )
if [ -z "$warpurl" ] || printf '%s' "$warpurl" | grep -q html; then
wpv6='2606:4700:110:8d8d:1845:c39f:2dd5:a03a'
pvk='52cuYFgCJXp0LAq7+nWJIbCXXgU9eGggOc+Hlfz5u6A='
res='[215, 69, 233]'
else
pvk=$(echo "$warpurl" | awk -F'：' '/Private_key/{print $2}' | xargs)
wpv6=$(echo "$warpurl" | awk -F'：' '/IPV6/{print $2}' | xargs)
res=$(echo "$warpurl" | awk -F'：' '/reserved/{print $2}' | xargs)
fi
if [ -n "$name" ]; then
sxname=$name-
echo "$sxname" > "$HOME/agsbx/name"
echo
echo "所有节点名称前缀：$name"
fi
v4v6
if echo "$v6" | grep -q '^2a09' || echo "$v4" | grep -q '^104.28'; then
s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo
echo; echo "请注意：你已安装了warp"
else
if [ "$wap" != yes ]; then
s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo
else
case "$warp" in
""|sx|xs) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s ) s1outtag=warp-out; s2outtag=warp-out; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s4) s1outtag=warp-out; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s6) s1outtag=warp-out; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
x ) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
x4) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
x6) s1outtag=direct; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
s4x4|x4s4) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s4x6|x6s4) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
s6x4|x4s6) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
s6x6|x6s6) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0"'; wap=warp ;;
sx4|x4s) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=direct; xip='"0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
sx6|x6s) s1outtag=warp-out; s2outtag=warp-out; x1outtag=warp-out; x2outtag=direct; xip='"::/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warp ;;
xs4|s4x) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"0.0.0.0/0"'; wap=warp ;;
xs6|s6x) s1outtag=warp-out; s2outtag=direct; x1outtag=warp-out; x2outtag=warp-out; xip='"::/0", "0.0.0.0/0"'; sip='"::/0"'; wap=warp ;;
* ) s1outtag=direct; s2outtag=direct; x1outtag=direct; x2outtag=direct; xip='"::/0", "0.0.0.0/0"'; sip='"::/0", "0.0.0.0/0"'; wap=warpargo ;;
esac
fi
fi
case "$warp" in *x4*) wxryx='ForceIPv4' ;; *x6*) wxryx='ForceIPv6' ;; *) wxryx='ForceIPv6v4' ;; esac
if command -v curl >/dev/null 2>&1; then
curl -s4m5 -k "$v46url" >/dev/null 2>&1 && v4_ok=true
elif command -v wget >/dev/null 2>&1; then
timeout 3 wget -4 --tries=2 -qO- "$v46url" >/dev/null 2>&1 && v4_ok=true
fi
if command -v curl >/dev/null 2>&1; then
curl -s6m5 -k "$v46url" >/dev/null 2>&1 && v6_ok=true
elif command -v wget >/dev/null 2>&1; then
timeout 3 wget -6 --tries=2 -qO- "$v46url" >/dev/null 2>&1 && v6_ok=true
fi
if [ "$v4_ok" = true ] && [ "$v6_ok" = true ]; then
case "$warp" in *s4*) sbyx='prefer_ipv4' ;; *) sbyx='prefer_ipv6' ;; esac
case "$warp" in *x4*) xryx='ForceIPv4v6' ;; *x*) xryx='ForceIPv6v4' ;; *) xryx='ForceIPv4v6' ;; esac
elif [ "$v4_ok" = true ] && [ "$v6_ok" != true ]; then
case "$warp" in *s4*|x) sbyx='ipv4_only' ;; *) sbyx='prefer_ipv6' ;; esac
case "$warp" in *x4*) xryx='ForceIPv4' ;; *x*) xryx='ForceIPv6v4' ;; *) xryx='ForceIPv4v6' ;; esac
elif [ "$v4_ok" != true ] && [ "$v6_ok" = true ]; then
case "$warp" in *s6*|x) sbyx='ipv6_only' ;; *) sbyx='prefer_ipv4' ;; esac
case "$warp" in *x6*) xryx='ForceIPv6' ;; *x*) xryx='ForceIPv4v6' ;; *) xryx='ForceIPv6v4' ;; esac
fi
}
upxray(){
url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/xray-$cpu"; out="$HOME/agsbx/xray"; (command -v curl >/dev/null 2>&1 && curl -Lo "$out" -# --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -O "$out" --tries=2 "$url")
chmod +x "$HOME/agsbx/xray"
sbcore=$("$HOME/agsbx/xray" version 2>/dev/null | awk '/^Xray/{print $2}')
echo "已安装Xray正式版内核：$sbcore"
}
upsingbox(){
url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/sing-box-$cpu"; out="$HOME/agsbx/sing-box"; (command -v curl>/dev/null 2>&1 && curl -Lo "$out" -# --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -O "$out" --tries=2 "$url")
chmod +x "$HOME/agsbx/sing-box"
sbcore=$("$HOME/agsbx/sing-box" version 2>/dev/null | awk '/version/{print $NF}')
echo "已安装Sing-box正式版内核：$sbcore"
}
download_file(){
url=$1
out=$2
if command -v curl >/dev/null 2>&1; then
curl -fL --retry 3 --connect-timeout 10 -o "$out" "$url"
elif command -v wget >/dev/null 2>&1; then
wget -O "$out" --tries=3 --timeout=20 "$url"
else
echo "错误：系统缺少 curl 或 wget" >&2
return 1
fi
}
port_spec_is_valid(){
printf '%s' "$1" | grep -Eq '^[1-9][0-9]*(-[1-9][0-9]*)?$' || return 1
case "$1" in
*-*) start=${1%-*}; end=${1#*-} ;;
*) start=$1; end=$1 ;;
esac
[ "$start" -ge 1025 ] 2>/dev/null && [ "$end" -le 65535 ] 2>/dev/null && [ "$start" -le "$end" ] 2>/dev/null
}
validate_mieru_port_spec(){
spec=$1
label=$2
case "$spec" in
*,*|*' '*|*'\t'*) echo "错误：$label 仅支持单端口或递增范围，不支持逗号列表和空格：$spec" >&2; return 1 ;;
esac
port_spec_is_valid "$spec" || {
echo "错误：$label 必须是 1025-65535 的单端口或递增范围，例如 5000 或 5000-5010：$spec" >&2
return 1
}
case "$spec" in
*-*) [ "${spec%-*}" -lt "${spec#*-}" ] || { echo "错误：$label 范围必须严格递增：$spec" >&2; return 1; } ;;
esac
}
port_spec_contains(){
spec=$1
port=$2
case "$spec" in
*-*) start=${spec%-*}; end=${spec#*-} ;;
*) start=$spec; end=$spec ;;
esac
[ "$port" -ge "$start" ] 2>/dev/null && [ "$port" -le "$end" ] 2>/dev/null
}
port_specs_overlap(){
a=$1
b=$2
case "$a" in *-*) a1=${a%-*}; a2=${a#*-} ;; *) a1=$a; a2=$a ;; esac
case "$b" in *-*) b1=${b%-*}; b2=${b#*-} ;; *) b1=$b; b2=$b ;; esac
[ "$a1" -le "$b2" ] && [ "$b1" -le "$a2" ]
}
legacy_port_conflict(){
spec=$1
for file in "$HOME/agsbx"/port_*; do
[ -f "$file" ] || continue
case "$(basename "$file")" in port_mi_tcp|port_mi_udp) continue ;; esac
other=$(cat "$file" 2>/dev/null)
port_spec_is_valid "$other" || continue
if port_specs_overlap "$spec" "$other"; then
echo "错误：Mieru 端口 $spec 与现有 Argosbx 端口文件 $(basename "$file")=$other 冲突" >&2
return 0
fi
done
for other in "$port_vl_re" "$port_vm_ws" "$port_vw" "$port_hy2" "$port_tu" "$port_xh" "$port_vx" "$port_an" "$port_ar" "$port_ss" "$port_so"; do
port_spec_is_valid "$other" || continue
if port_specs_overlap "$spec" "$other"; then
echo "错误：Mieru 端口 $spec 与本次选择的 Argosbx 端口 $other 冲突" >&2
return 0
fi
done
return 1
}
listener_conflict(){
protocol=$1
spec=$2
if command -v ss >/dev/null 2>&1; then
case "$protocol" in TCP) lines=$(ss -H -ltnp 2>/dev/null) ;; UDP) lines=$(ss -H -lunp 2>/dev/null) ;; esac
elif command -v netstat >/dev/null 2>&1; then
case "$protocol" in TCP) lines=$(netstat -lntp 2>/dev/null | sed '1,2d') ;; UDP) lines=$(netstat -lnup 2>/dev/null | sed '1,2d') ;; esac
else
echo "警告：缺少 ss/netstat，无法检查系统监听端口冲突" >&2
return 1
fi
[ -n "$lines" ] || return 1
old_spec=''
case "$protocol" in
TCP) old_spec=$(cat "$HOME/agsbx/port_mi_tcp" 2>/dev/null) ;;
UDP) old_spec=$(cat "$HOME/agsbx/port_mi_udp" 2>/dev/null) ;;
esac
while IFS= read -r line; do
set -- $line
local_addr=${4:-}
port=${local_addr##*:}
port=${port%]}
case "$port" in ''|*[!0-9]*) continue ;; esac
port_spec_contains "$spec" "$port" || continue
own_mita=no
for exe in /proc/[0-9]*/exe; do
[ -L "$exe" ] || continue
if [ "$(readlink -f "$exe" 2>/dev/null)" = "$(readlink -f "$HOME/agsbx/mita" 2>/dev/null)" ]; then
pid=$(basename "$(dirname "$exe")")
printf '%s' "$line" | grep -q "pid=$pid," && own_mita=yes
fi
done
if [ "$own_mita" != yes ] && is_exe_running "$HOME/agsbx/mita" && port_spec_is_valid "$old_spec" && port_spec_contains "$old_spec" "$port"; then
own_mita=yes
fi
if [ "$own_mita" != yes ]; then
echo "错误：Mieru $protocol 端口 $port 已被系统监听：$line" >&2
return 0
fi
done <<EOF
$lines
EOF
return 1
}
mieru_port_conflict(){
protocol=$1
spec=$2
legacy_port_conflict "$spec" && return 0
listener_conflict "$protocol" "$spec" && return 0
return 1
}
random_port_number(){
if command -v shuf >/dev/null 2>&1; then
shuf -i 1025-65535 -n 1
else
n=$(od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d ' ')
echo $((n % 64511 + 1025))
fi
}
subscription_token_is_valid(){
printf '%s' "$1" | LC_ALL=C grep -Eq '^[A-Za-z0-9._~-]{1,128}$'
}
subscription_port_is_valid(){
case "$1" in ''|*[!0-9]*) return 1 ;; esac
[ "$1" -ge 1025 ] 2>/dev/null && [ "$1" -le 65535 ] 2>/dev/null
}
subscription_tcp_port_in_use(){
subsrv_check_port=$1
if command -v ss >/dev/null 2>&1; then
subsrv_lines=$(ss -H -ltn 2>/dev/null)
elif command -v netstat >/dev/null 2>&1; then
subsrv_lines=$(netstat -lnt 2>/dev/null | sed '1,2d')
else
echo "警告：缺少 ss/netstat，无法检查订阅 TCP 端口冲突" >&2
return 1
fi
while IFS= read -r subsrv_line; do
set -- $subsrv_line
subsrv_addr=${4:-}
subsrv_found_port=${subsrv_addr##*:}
subsrv_found_port=${subsrv_found_port%]}
[ "$subsrv_found_port" = "$subsrv_check_port" ] && return 0
done <<EOF
$subsrv_lines
EOF
return 1
}
stop_subscription_server(){
subsrv_pid=$(cat "$HOME/agsbx/sub-http.pid" 2>/dev/null)
case "$subsrv_pid" in
''|*[!0-9]*) ;;
*)
if [ -r "/proc/$subsrv_pid/cmdline" ] && grep -aFq "$HOME/websbx" "/proc/$subsrv_pid/cmdline" 2>/dev/null; then
kill -15 "$subsrv_pid" 2>/dev/null || true
fi
;;
esac
pkill -f 'busybox.*httpd.*websbx' >/dev/null 2>&1 || true
rm -f "$HOME/agsbx/sub-http.pid"
}
sync_subscription_files(){
subsrv_token=$(cat "$HOME/agsbx/subtoken.log" 2>/dev/null)
subscription_token_is_valid "$subsrv_token" || {
echo "错误：订阅 token 必须是 1-128 位 URL-safe ASCII" >&2
return 1
}
subsrv_dir="$HOME/websbx/$subsrv_token"
mkdir -p "$subsrv_dir" || return 1
chmod 0700 "$HOME/websbx" "$subsrv_dir" 2>/dev/null || true
subsrv_count=0
for subsrv_file in clmi.yaml sbox.json jhsub.txt mieru.txt; do
if [ -s "$HOME/agsbx/$subsrv_file" ]; then
ln -sfn "$HOME/agsbx/$subsrv_file" "$subsrv_dir/$subsrv_file" || return 1
subsrv_count=$((subsrv_count+1))
else
rm -f "$subsrv_dir/$subsrv_file"
fi
done
[ "$subsrv_count" -gt 0 ] || {
echo "错误：没有可发布的订阅文件" >&2
return 1
}
}
subscription_probe(){
subsrv_port=$(cat "$HOME/agsbx/subport.log" 2>/dev/null)
subsrv_token=$(cat "$HOME/agsbx/subtoken.log" 2>/dev/null)
subscription_port_is_valid "$subsrv_port" || return 1
subscription_token_is_valid "$subsrv_token" || return 1
subsrv_probe_file=''
for subsrv_file in jhsub.txt clmi.yaml sbox.json mieru.txt; do
if [ -s "$HOME/agsbx/$subsrv_file" ] && [ -e "$HOME/websbx/$subsrv_token/$subsrv_file" ]; then
subsrv_probe_file=$subsrv_file
break
fi
done
[ -n "$subsrv_probe_file" ] || return 1
subsrv_probe_url="http://127.0.0.1:$subsrv_port/$subsrv_token/$subsrv_probe_file"
if command -v curl >/dev/null 2>&1; then
curl -fsS --connect-timeout 2 --max-time 5 "$subsrv_probe_url" >/dev/null 2>&1
elif command -v wget >/dev/null 2>&1; then
wget -qO /dev/null --timeout=5 "$subsrv_probe_url" >/dev/null 2>&1
else
busybox wget -qO- "$subsrv_probe_url" >/dev/null 2>&1
fi
}
start_subscription_server(){
subsrv_port=$(cat "$HOME/agsbx/subport.log" 2>/dev/null)
subsrv_token=$(cat "$HOME/agsbx/subtoken.log" 2>/dev/null)
subscription_port_is_valid "$subsrv_port" || {
echo "错误：订阅端口必须是 1025-65535 的单端口" >&2
return 1
}
subscription_token_is_valid "$subsrv_token" || {
echo "错误：订阅 token 必须是 1-128 位 URL-safe ASCII" >&2
return 1
}
stop_subscription_server
sleep 1
if subscription_tcp_port_in_use "$subsrv_port"; then
echo "错误：订阅 TCP 端口 $subsrv_port 已被其他进程占用" >&2
return 1
fi
: > "$HOME/agsbx/sub-http.log"
if command -v apk >/dev/null 2>&1; then
nohup busybox-extras httpd -f -p "$subsrv_port" -h "$HOME/websbx" > "$HOME/agsbx/sub-http.log" 2>&1 &
else
nohup busybox httpd -f -p "$subsrv_port" -h "$HOME/websbx" > "$HOME/agsbx/sub-http.log" 2>&1 &
fi
subsrv_pid=$!
printf '%s\n' "$subsrv_pid" > "$HOME/agsbx/sub-http.pid"
chmod 0600 "$HOME/agsbx/sub-http.pid" "$HOME/agsbx/sub-http.log" 2>/dev/null || true
sleep 1
if ! kill -0 "$subsrv_pid" 2>/dev/null; then
echo "错误：订阅 HTTP 服务启动失败：$(cat "$HOME/agsbx/sub-http.log" 2>/dev/null)" >&2
rm -f "$HOME/agsbx/sub-http.pid"
return 1
fi
}
choose_subscription_port(){
subsrv_requested=${subpt:-}
subsrv_saved=$(cat "$HOME/agsbx/subport.log" 2>/dev/null)
subsrv_candidate=''
if [ -n "$subsrv_requested" ]; then
subscription_port_is_valid "$subsrv_requested" || {
echo "错误：subpt 必须是 1025-65535 的单端口" >&2
return 1
}
subsrv_candidate=$subsrv_requested
elif subscription_port_is_valid "$subsrv_saved"; then
subsrv_candidate=$subsrv_saved
fi
if [ -n "$subsrv_candidate" ] && ! subscription_tcp_port_in_use "$subsrv_candidate"; then
printf '%s\n' "$subsrv_candidate"
return 0
fi
if [ -n "$subsrv_requested" ]; then
echo "错误：指定的订阅 TCP 端口 $subsrv_candidate 已被占用" >&2
return 1
fi
[ -n "$subsrv_candidate" ] && echo "警告：原订阅端口 $subsrv_candidate 已被占用，将生成新端口" >&2
subsrv_i=0
while [ "$subsrv_i" -lt 1000 ]; do
subsrv_candidate=$(random_port_number)
if [ "$subsrv_candidate" -ge 10000 ] 2>/dev/null && ! subscription_tcp_port_in_use "$subsrv_candidate"; then
printf '%s\n' "$subsrv_candidate"
return 0
fi
subsrv_i=$((subsrv_i+1))
done
echo "错误：未能找到可用的订阅 TCP 端口" >&2
return 1
}
ensure_subscription_available(){
sync_subscription_files || return 1
subscription_probe && return 0
start_subscription_server || return 1
sync_subscription_files || return 1
subscription_probe
}
choose_random_mieru_port(){
protocol=$1
avoid=${2:-}
i=0
while [ "$i" -lt 1000 ]; do
candidate=$(random_port_number)
[ -n "$avoid" ] && [ "$candidate" = "$avoid" ] && { i=$((i+1)); continue; }
if ! mieru_port_conflict "$protocol" "$candidate"; then
printf '%s\n' "$candidate"
return 0
fi
i=$((i+1))
done
echo "错误：未能找到可用的 Mieru $protocol 随机端口" >&2
return 1
}
generate_mieru_password(){
if command -v openssl >/dev/null 2>&1; then
openssl rand -base64 24 | tr '+/' '-_' | tr -d '=\r\n'
else
head -c 24 /dev/urandom | base64 | tr '+/' '-_' | tr -d '=\r\n'
fi
}
generate_uuid_token(){
if [ -r /proc/sys/kernel/random/uuid ]; then
cat /proc/sys/kernel/random/uuid
elif command -v uuidgen >/dev/null 2>&1; then
uuidgen | tr 'A-Z' 'a-z'
else
hex=$(openssl rand -hex 16)
printf '%s-%s-4%s-%x%s-%s\n' "${hex%????????????????????????}" "$(printf '%s' "$hex" | cut -c9-12)" "$(printf '%s' "$hex" | cut -c14-16)" "$((0x$(printf '%s' "$hex" | cut -c17-17) % 4 + 8))" "$(printf '%s' "$hex" | cut -c18-20)" "$(printf '%s' "$hex" | cut -c21-32)"
fi
}
ensure_subscription_uuid(){
[ -s "$HOME/agsbx/uuid" ] && return 0
umask 077
generate_uuid_token > "$HOME/agsbx/uuid"
chmod 0600 "$HOME/agsbx/uuid"
}
prepare_mieru_credentials(){
old_user=$(cat "$HOME/agsbx/miuser" 2>/dev/null)
old_pass=$(cat "$HOME/agsbx/mipass" 2>/dev/null)
if [ -n "$miuser" ]; then
mieru_user=$miuser
elif [ -n "$old_user" ]; then
mieru_user=$old_user
else
mieru_user=argosbx
fi
if [ -n "$mipass" ]; then
mieru_pass=$mipass
elif [ -n "$old_pass" ]; then
mieru_pass=$old_pass
else
mieru_pass=$(generate_mieru_password)
fi
printf '%s' "$mieru_user" | LC_ALL=C grep -Eq '^[A-Za-z0-9._~-]{1,64}$' || {
echo "错误：miuser 必须是 1-64 位 URL-safe ASCII（字母、数字、点、下划线、波浪线或连字符）" >&2
return 1
}
printf '%s' "$mieru_pass" | LC_ALL=C grep -Eq '^[A-Za-z0-9._~-]{12,128}$' || {
echo "错误：mipass 必须是 12-128 位 URL-safe ASCII（字母、数字、点、下划线、波浪线或连字符）" >&2
return 1
}
}
prepare_mieru_settings(){
prepare_mieru_credentials || return 1
tcp_random=no
udp_random=no
if [ "$mit" = yes ]; then
if [ -n "$port_mi_tcp" ]; then
mieru_tcp=$port_mi_tcp
elif [ -s "$HOME/agsbx/port_mi_tcp" ]; then
mieru_tcp=$(cat "$HOME/agsbx/port_mi_tcp")
else
tcp_random=yes
mieru_tcp=$(choose_random_mieru_port TCP) || return 1
fi
validate_mieru_port_spec "$mieru_tcp" "mitpt" || return 1
mieru_port_conflict TCP "$mieru_tcp" && return 1
fi
if [ "$miu" = yes ]; then
if [ -n "$port_mi_udp" ]; then
mieru_udp=$port_mi_udp
elif [ -s "$HOME/agsbx/port_mi_udp" ]; then
mieru_udp=$(cat "$HOME/agsbx/port_mi_udp")
else
udp_random=yes
avoid=''
[ "$tcp_random" = yes ] && avoid=$mieru_tcp
mieru_udp=$(choose_random_mieru_port UDP "$avoid") || return 1
fi
validate_mieru_port_spec "$mieru_udp" "miupt" || return 1
mieru_port_conflict UDP "$mieru_udp" && return 1
fi
if [ "$tcp_random" = yes ] && [ "$udp_random" = yes ] && [ "$mieru_tcp" = "$mieru_udp" ]; then
echo "错误：随机生成的 Mieru TCP/UDP 端口不能相同" >&2
return 1
fi
umask 077
printf '%s\n' "$mieru_user" > "$HOME/agsbx/miuser"
printf '%s\n' "$mieru_pass" > "$HOME/agsbx/mipass"
chmod 0600 "$HOME/agsbx/miuser" "$HOME/agsbx/mipass"
if [ "$mit" = yes ]; then
printf '%s\n' "$mieru_tcp" > "$HOME/agsbx/port_mi_tcp"
: > "$HOME/agsbx/mieru_tcp.enabled"
else
rm -f "$HOME/agsbx/mieru_tcp.enabled"
fi
if [ "$miu" = yes ]; then
printf '%s\n' "$mieru_udp" > "$HOME/agsbx/port_mi_udp"
: > "$HOME/agsbx/mieru_udp.enabled"
else
rm -f "$HOME/agsbx/mieru_udp.enabled"
fi
chmod 0600 "$HOME/agsbx"/port_mi_* "$HOME/agsbx"/mieru_*.enabled 2>/dev/null || true
ensure_subscription_uuid
}
stage_mieru_cores(){
MIERU_STAGE_DIR="$HOME/agsbx/.mieru-download.$$"
rm -rf "$MIERU_STAGE_DIR"
mkdir -p "$MIERU_STAGE_DIR" || return 1
sums="$MIERU_STAGE_DIR/SHA256SUMS"
download_file "$MIERU_RELEASE_BASE/SHA256SUMS" "$sums" || { rm -rf "$MIERU_STAGE_DIR"; return 1; }
for core in mita mieru; do
asset="$core-linux-$cpu"
download_file "$MIERU_RELEASE_BASE/$asset" "$MIERU_STAGE_DIR/$asset" || { rm -rf "$MIERU_STAGE_DIR"; return 1; }
expected=$(awk -v name="$asset" '{n=$2; sub(/^\*/, "", n); if (n==name) {print $1; exit}}' "$sums")
[ -n "$expected" ] || { echo "错误：SHA256SUMS 缺少 $asset" >&2; rm -rf "$MIERU_STAGE_DIR"; return 1; }
actual=$(sha256sum "$MIERU_STAGE_DIR/$asset" | awk '{print $1}')
[ "$actual" = "$expected" ] || { echo "错误：$asset SHA-256 校验失败" >&2; rm -rf "$MIERU_STAGE_DIR"; return 1; }
chmod 0755 "$MIERU_STAGE_DIR/$asset"
done
}
activate_staged_mieru_cores(){
for core in mita mieru; do
asset="$core-linux-$cpu"
new="$HOME/agsbx/.$core.new.$$"
mv "$MIERU_STAGE_DIR/$asset" "$new" || {
rm -f "$HOME/agsbx"/.mita.new.$$ "$HOME/agsbx"/.mieru.new.$$
return 1
}
chmod 0755 "$new"
mv -f "$new" "$HOME/agsbx/$core" || {
rm -f "$HOME/agsbx"/.mita.new.$$ "$HOME/agsbx"/.mieru.new.$$
return 1
}
done
rm -rf "$MIERU_STAGE_DIR"
}
ensure_mieru_cores(){
[ -x "$HOME/agsbx/mita" ] && [ -x "$HOME/agsbx/mieru" ] && return 0
echo "下载并校验 Mieru $MIERU_VERSION 的 mita/mieru 静态内核……"
stage_mieru_cores || return 1
activate_staged_mieru_cores || { rm -rf "$MIERU_STAGE_DIR"; return 1; }
}
mita_env_status(){
env MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json" MITA_UDS_PATH="$HOME/agsbx/mita.sock" MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true "$HOME/agsbx/mita" status 2>&1
}
mita_running(){
[ -x "$HOME/agsbx/mita" ] || return 1
mita_env_status | grep -q 'status is "RUNNING"'
}
stop_mita_runtime(){
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1; then
systemctl stop argosbx-mita.service >/dev/null 2>&1 || true
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1; then
rc-service argosbx-mita stop >/dev/null 2>&1 || true
fi
kill_exe "$HOME/agsbx/mita" TERM
sleep 1
is_exe_running "$HOME/agsbx/mita" && kill_exe "$HOME/agsbx/mita" KILL
rm -f "$HOME/agsbx/mita.sock" "$HOME/agsbx/mita.pid"
}
remove_mita_service(){
stop_mita_runtime
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1; then
systemctl disable argosbx-mita.service >/dev/null 2>&1 || true
rm -f /etc/systemd/system/argosbx-mita.service
systemctl daemon-reload >/dev/null 2>&1 || true
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1; then
rc-update del argosbx-mita default >/dev/null 2>&1 || true
rm -f /etc/init.d/argosbx-mita
fi
}
start_mita_runtime(){
rm -f "$HOME/agsbx/mita.sock" "$HOME/agsbx/mita.pid"
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1; then
cat > /etc/systemd/system/argosbx-mita.service <<EOF
[Unit]
Description=Argosbx Mita service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment="MITA_CONFIG_JSON_FILE=$HOME/agsbx/mita.json"
Environment="MITA_UDS_PATH=$HOME/agsbx/mita.sock"
Environment="MITA_INSECURE_UDS=1"
Environment="MITA_LOG_NO_TIMESTAMP=true"
ExecStart=$HOME/agsbx/mita run
Restart=on-failure
RestartSec=5s
NoNewPrivileges=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable argosbx-mita.service >/dev/null 2>&1
systemctl restart argosbx-mita.service >/dev/null 2>&1
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1; then
cat > /etc/init.d/argosbx-mita <<EOF
#!/sbin/openrc-run
description="Argosbx Mita service"
command="$HOME/agsbx/mita"
command_args="run"
command_background="yes"
pidfile="$HOME/agsbx/mita.pid"
output_log="$HOME/agsbx/mita.log"
error_log="$HOME/agsbx/mita.log"
export MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json"
export MITA_UDS_PATH="$HOME/agsbx/mita.sock"
export MITA_INSECURE_UDS="1"
export MITA_LOG_NO_TIMESTAMP="true"
depend() {
need net
}
EOF
chmod 0755 /etc/init.d/argosbx-mita
rc-update add argosbx-mita default >/dev/null 2>&1
rc-service argosbx-mita restart >/dev/null 2>&1
else
kill_exe "$HOME/agsbx/mita" TERM
nohup env MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json" MITA_UDS_PATH="$HOME/agsbx/mita.sock" MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true "$HOME/agsbx/mita" run > "$HOME/agsbx/mita.log" 2>&1 &
printf '%s\n' "$!" > "$HOME/agsbx/mita.pid"
chmod 0600 "$HOME/agsbx/mita.log" "$HOME/agsbx/mita.pid" 2>/dev/null || true
fi
}
wait_mita_running(){
i=0
while [ "$i" -lt 10 ]; do
mita_running && return 0
sleep 1
i=$((i+1))
done
mita_env_status >&2 || true
return 1
}
write_mita_config(){
umask 077
{
cat <<EOF
{
  "portBindings": [
EOF
first=yes
if [ "$mit" = yes ]; then
[ "$first" = yes ] || echo ','
case "$mieru_tcp" in
*-*) printf '    {"portRange": "%s", "protocol": "TCP"}' "$mieru_tcp" ;;
*) printf '    {"port": %s, "protocol": "TCP"}' "$mieru_tcp" ;;
esac
first=no
fi
if [ "$miu" = yes ]; then
[ "$first" = yes ] || echo ','
case "$mieru_udp" in
*-*) printf '    {"portRange": "%s", "protocol": "UDP"}' "$mieru_udp" ;;
*) printf '    {"port": %s, "protocol": "UDP"}' "$mieru_udp" ;;
esac
first=no
fi
cat <<EOF

  ],
  "users": [
    {"name": "$mieru_user", "password": "$mieru_pass"}
  ],
  "loggingLevel": "INFO",
  "mtu": 1400
}
EOF
} > "$HOME/agsbx/mita.json"
chmod 0600 "$HOME/agsbx/mita.json"
}
warn_mieru_clock(){
if command -v timedatectl >/dev/null 2>&1; then
synced=$(timedatectl show -p NTPSynchronized --value 2>/dev/null)
[ "$synced" = yes ] || echo "警告：系统时钟似乎尚未同步；Mieru 客户端和服务端时间偏差会导致连接失败"
fi
}
installmita(){
echo
echo "=========启用 Mieru Mita 独立内核========="
prepare_mieru_settings || return 1
ensure_mieru_cores || return 1
write_mita_config || return 1
warn_mieru_clock
[ "$wap" = yes ] && echo "提示：WARP 仅作用于 Xray/sing-box，Mieru 保持公网直连"
echo "提示：请在防火墙和云安全组放行完整 Mieru TCP/UDP 端口或范围"
start_mita_runtime || return 1
if wait_mita_running; then
echo "Mita $MIERU_VERSION 已运行，配置文件：$HOME/agsbx/mita.json"
else
echo "错误：Mita 启动失败，请检查 $HOME/agsbx/mita.log 或系统服务日志" >&2
return 1
fi
}
cleanup_mieru_runtime(){
remove_mita_service
rm -f "$HOME/agsbx/mita.json" "$HOME/agsbx/mita.sock" "$HOME/agsbx/mita.pid" "$HOME/agsbx/mita.log" "$HOME/agsbx/mieru.txt" "$HOME/agsbx/mieru_tcp.enabled" "$HOME/agsbx/mieru_udp.enabled"
rm -f "$HOME/agsbx"/.mieru-client.* "$HOME/agsbx"/.mieru-links.*
}
update_mieru_cores(){
[ -f "$HOME/agsbx/mita.json" ] || { echo "错误：当前未启用 Mieru，无法执行 upm" >&2; return 1; }
[ -x "$HOME/agsbx/mita" ] && [ -x "$HOME/agsbx/mieru" ] || { echo "错误：现有 Mieru 内核不完整，请先 rep 重新安装" >&2; return 1; }
echo "下载并校验 Mieru $MIERU_VERSION 更新……"
stage_mieru_cores || { echo "Mieru 更新下载或校验失败，旧内核及运行服务保持不变" >&2; return 1; }
backup_mita="$HOME/agsbx/.mita.rollback.$$"
backup_mieru="$HOME/agsbx/.mieru.rollback.$$"
cp -p "$HOME/agsbx/mita" "$backup_mita" && cp -p "$HOME/agsbx/mieru" "$backup_mieru" || {
rm -rf "$MIERU_STAGE_DIR" "$backup_mita" "$backup_mieru"
echo "Mieru 更新备份失败，旧服务保持不变" >&2
return 1
}
stop_mita_runtime
update_failure="Mieru 新内核启动或状态验证失败"
if activate_staged_mieru_cores && start_mita_runtime && wait_mita_running; then
server_ip=$(cat "$HOME/agsbx/server_ip.log" 2>/dev/null)
if [ -n "$server_ip" ] && generate_mieru_links; then
rm -f "$backup_mita" "$backup_mieru"
echo "Mita 与 mieru 已更新到 $MIERU_VERSION"
return 0
fi
update_failure="Mieru 更新后的分享链接生成失败"
fi
echo "$update_failure，正在回滚旧内核……" >&2
stop_mita_runtime
rm -rf "$MIERU_STAGE_DIR"
mv -f "$backup_mita" "$HOME/agsbx/mita"
mv -f "$backup_mieru" "$HOME/agsbx/mieru"
chmod 0755 "$HOME/agsbx/mita" "$HOME/agsbx/mieru"
start_mita_runtime >/dev/null 2>&1 || true
wait_mita_running >/dev/null 2>&1 || true
return 1
}
configured_cores_running(){
found=no
if [ -f "$HOME/agsbx/xr.json" ]; then
found=yes
is_exe_running "$HOME/agsbx/xray" || return 1
fi
if [ -f "$HOME/agsbx/sb.json" ]; then
found=yes
is_exe_running "$HOME/agsbx/sing-box" || return 1
fi
if [ -f "$HOME/agsbx/mita.json" ]; then
found=yes
mita_running || return 1
fi
[ "$found" = yes ]
}
write_mieru_client_config(){
local out tcp_spec udp_spec address ip_address domain_name user pass first entry
out=$1
tcp_spec=$2
udp_spec=$3
address=${server_ip#[}
address=${address%]}
case "$address" in
*:*|[0-9]*.[0-9]*.[0-9]*.[0-9]*) ip_address=$address; domain_name='' ;;
*) ip_address=''; domain_name=$address ;;
esac
user=$(cat "$HOME/agsbx/miuser")
pass=$(cat "$HOME/agsbx/mipass")
umask 077
{
cat <<EOF
{
  "profiles": [
    {
      "profileName": "argosbx",
      "user": {"name": "$user", "password": "$pass"},
      "servers": [
        {
          "ipAddress": "$ip_address",
          "domainName": "$domain_name",
          "portBindings": [
EOF
first=yes
if [ -n "$tcp_spec" ]; then
case "$tcp_spec" in *-*) entry="{\"portRange\": \"$tcp_spec\", \"protocol\": \"TCP\"}" ;; *) entry="{\"port\": $tcp_spec, \"protocol\": \"TCP\"}" ;; esac
printf '            %s' "$entry"
first=no
fi
if [ -n "$udp_spec" ]; then
[ "$first" = yes ] || echo ','
case "$udp_spec" in *-*) entry="{\"portRange\": \"$udp_spec\", \"protocol\": \"UDP\"}" ;; *) entry="{\"port\": $udp_spec, \"protocol\": \"UDP\"}" ;; esac
printf '            %s' "$entry"
first=no
fi
cat <<EOF

          ]
        }
      ],
      "mtu": 1400
    }
  ],
  "activeProfile": "argosbx",
  "rpcPort": 0,
  "socks5Port": 1080,
  "loggingLevel": "INFO",
  "socks5ListenLAN": false
}
EOF
} > "$out"
chmod 0600 "$out"
}
export_mieru_link(){
local config mode output link
config=$1
mode=${2:-standard}
if [ "$mode" = simple ]; then
output=$(MIERU_CONFIG_JSON_FILE="$config" "$HOME/agsbx/mieru" export config simple 2>&1)
else
output=$(MIERU_CONFIG_JSON_FILE="$config" "$HOME/agsbx/mieru" export config 2>&1)
fi
link=$(printf '%s\n' "$output" | grep -Eo 'mierus?://[^[:space:]]+' | tail -n 1)
[ -n "$link" ] || { printf '%s\n' "$output" >&2; return 1; }
printf '%s\n' "$link"
}
validate_mieru_link(){
"$HOME/agsbx/mieru" explain config "$1" >/dev/null 2>&1
}
generate_mieru_links(){
local tcp_spec udp_spec combo_cfg standard_link combo_link tcp_link udp_link tcp_cfg udp_cfg links_tmp
mierushow=''
[ -f "$HOME/agsbx/mita.json" ] || return 0
[ -x "$HOME/agsbx/mieru" ] || { echo "错误：缺少 mieru 客户端二进制，无法生成分享链接" >&2; return 1; }
tcp_spec=''; udp_spec=''
[ -f "$HOME/agsbx/mieru_tcp.enabled" ] && tcp_spec=$(cat "$HOME/agsbx/port_mi_tcp")
[ -f "$HOME/agsbx/mieru_udp.enabled" ] && udp_spec=$(cat "$HOME/agsbx/port_mi_udp")
[ -n "$tcp_spec$udp_spec" ] || { echo "错误：Mieru 配置缺少启用的端口绑定" >&2; return 1; }
combo_cfg="$HOME/agsbx/.mieru-client.combo.$$"
write_mieru_client_config "$combo_cfg" "$tcp_spec" "$udp_spec"
standard_link=$(export_mieru_link "$combo_cfg" standard) || { rm -f "$combo_cfg"; return 1; }
combo_link=$(export_mieru_link "$combo_cfg" simple) || { rm -f "$combo_cfg"; return 1; }
validate_mieru_link "$standard_link" && validate_mieru_link "$combo_link" || { echo "错误：Mieru 组合分享链接自检失败" >&2; rm -f "$combo_cfg"; return 1; }
tcp_link=''; udp_link=''
if [ -n "$tcp_spec" ] && [ -n "$udp_spec" ]; then
tcp_cfg="$HOME/agsbx/.mieru-client.tcp.$$"
udp_cfg="$HOME/agsbx/.mieru-client.udp.$$"
write_mieru_client_config "$tcp_cfg" "$tcp_spec" ''
write_mieru_client_config "$udp_cfg" '' "$udp_spec"
tcp_link=$(export_mieru_link "$tcp_cfg" simple) || { rm -f "$combo_cfg" "$tcp_cfg" "$udp_cfg"; return 1; }
udp_link=$(export_mieru_link "$udp_cfg" simple) || { rm -f "$combo_cfg" "$tcp_cfg" "$udp_cfg"; return 1; }
validate_mieru_link "$tcp_link" && validate_mieru_link "$udp_link" || { echo "错误：Mieru 独立分享链接自检失败" >&2; rm -f "$combo_cfg" "$tcp_cfg" "$udp_cfg"; return 1; }
fi
links_tmp="$HOME/agsbx/.mieru-links.$$"
umask 077
{
printf '%s\n' "$combo_link"
[ -n "$tcp_link" ] && printf '%s\n' "$tcp_link"
[ -n "$udp_link" ] && printf '%s\n' "$udp_link"
printf '%s\n' "$standard_link"
} > "$links_tmp"
chmod 0600 "$links_tmp"
mv -f "$links_tmp" "$HOME/agsbx/mieru.txt"
printf '%s\n' "$combo_link" >> "$HOME/agsbx/jhsub.txt"
chmod 0600 "$HOME/agsbx/jhsub.txt" 2>/dev/null || true
rm -f "$combo_cfg" "$tcp_cfg" "$udp_cfg"
mierushow="Mieru $MIERU_VERSION 公网直连节点：
组合简单链接：$combo_link"
[ -n "$tcp_link" ] && mierushow="$mierushow
TCP 独立简单链接：$tcp_link"
[ -n "$udp_link" ] && mierushow="$mierushow
UDP 独立简单链接：$udp_link"
mierushow="$mierushow
标准配置链接：$standard_link"
}
clmieru(){
local server user pass spec
server=${server_ip#[}
server=${server%]}
user=$(cat "$HOME/agsbx/miuser" 2>/dev/null)
pass=$(cat "$HOME/agsbx/mipass" 2>/dev/null)
if [ -f "$HOME/agsbx/mieru_tcp.enabled" ]; then
spec=$(cat "$HOME/agsbx/port_mi_tcp")
cat <<EOF
- name: Mieru-TCP-$hostname
  type: mieru
  server: "$server"
EOF
case "$spec" in *-*) echo "  port-range: \"$spec\"" ;; *) echo "  port: $spec" ;; esac
cat <<EOF
  transport: TCP
  username: "$user"
  password: "$pass"
EOF
fi
if [ -f "$HOME/agsbx/mieru_udp.enabled" ]; then
spec=$(cat "$HOME/agsbx/port_mi_udp")
cat <<EOF
- name: Mieru-UDP-$hostname
  type: mieru
  server: "$server"
EOF
case "$spec" in *-*) echo "  port-range: \"$spec\"" ;; *) echo "  port: $spec" ;; esac
cat <<EOF
  transport: UDP
  username: "$user"
  password: "$pass"
EOF
fi
}
clmieru1(){
[ -f "$HOME/agsbx/mieru_tcp.enabled" ] && echo "- Mieru-TCP-$hostname"
[ -f "$HOME/agsbx/mieru_udp.enabled" ] && echo "- Mieru-UDP-$hostname"
}
mitarestart(){
[ -f "$HOME/agsbx/mita.json" ] || return 0
stop_mita_runtime
start_mita_runtime && wait_mita_running
}
insuuid(){
if [ -z "$uuid" ] && [ ! -e "$HOME/agsbx/uuid" ]; then
if [ -e "$HOME/agsbx/sing-box" ]; then
uuid=$("$HOME/agsbx/sing-box" generate uuid)
else
uuid=$("$HOME/agsbx/xray" uuid)
fi
echo "$uuid" > "$HOME/agsbx/uuid"
elif [ -n "$uuid" ]; then
echo "$uuid" > "$HOME/agsbx/uuid"
fi
uuid=$(cat "$HOME/agsbx/uuid")
echo "UUID密码：$uuid"
}
installxray(){
echo
echo "=========启用xray内核========="
mkdir -p "$HOME/agsbx/xrk"
if [ ! -e "$HOME/agsbx/xray" ]; then
upxray
fi
cat > "$HOME/agsbx/xr.json" <<EOF
{
  "log": {
  "loglevel": "none"
  },
  "inbounds": [
EOF
insuuid
if [ -n "$xhp" ] || [ -n "$vlp" ]; then
if [ -z "$ym_vl_re" ]; then
ym_vl_re=apple.com
fi
echo "$ym_vl_re" > "$HOME/agsbx/ym_vl_re"
echo "Reality域名：$ym_vl_re"
if [ ! -e "$HOME/agsbx/xrk/private_key" ]; then
key_pair=$("$HOME/agsbx/xray" x25519)
private_key=$(echo "$key_pair" | awk -F':' '/PrivateKey/ {print $2}' | xargs)
public_key=$(echo "$key_pair" | awk -F':' '/Password/ {print $2}' | xargs)
short_id=$(date +%s%N | sha256sum | cut -c 1-8)
echo "$private_key" > "$HOME/agsbx/xrk/private_key"
echo "$public_key" > "$HOME/agsbx/xrk/public_key"
echo "$short_id" > "$HOME/agsbx/xrk/short_id"
fi
private_key_x=$(cat "$HOME/agsbx/xrk/private_key")
public_key_x=$(cat "$HOME/agsbx/xrk/public_key")
short_id_x=$(cat "$HOME/agsbx/xrk/short_id")
fi
if [ -n "$xhp" ] || [ -n "$vxp" ] || [ -n "$vwp" ]; then
if [ ! -e "$HOME/agsbx/xrk/dekey" ]; then
vlkey=$("$HOME/agsbx/xray" vlessenc)
dekey=$(echo "$vlkey" | grep '"decryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
enkey=$(echo "$vlkey" | grep '"encryption":' | sed -n '2p' | cut -d' ' -f2- | tr -d '"')
echo "$dekey" > "$HOME/agsbx/xrk/dekey"
echo "$enkey" > "$HOME/agsbx/xrk/enkey"
fi
dekey=$(cat "$HOME/agsbx/xrk/dekey")
enkey=$(cat "$HOME/agsbx/xrk/enkey")
fi

if [ -n "$xhp" ]; then
xhp=xhpt
if [ -z "$port_xh" ] && [ ! -e "$HOME/agsbx/port_xh" ]; then
port_xh=$(shuf -i 10000-65535 -n 1)
echo "$port_xh" > "$HOME/agsbx/port_xh"
elif [ -n "$port_xh" ]; then
echo "$port_xh" > "$HOME/agsbx/port_xh"
fi
port_xh=$(cat "$HOME/agsbx/port_xh")
echo "Vless-xhttp-reality-enc端口：$port_xh"
cat >> "$HOME/agsbx/xr.json" <<EOF
    {
      "tag":"xhttp-reality",
      "listen": "::",
      "port": ${port_xh},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "${dekey}"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "reality",
        "realitySettings": {
          "fingerprint": "chrome",
          "target": "${ym_vl_re}:443",
          "serverNames": [
            "${ym_vl_re}"
          ],
          "privateKey": "$private_key_x",
          "shortIds": ["$short_id_x"]
        },
        "xhttpSettings": {
          "host": "",
          "path": "${uuid}-xh",
          "mode": "auto"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      }
    },
EOF
else
xhp=xhptargo
fi
if [ -n "$vxp" ]; then
vxp=vxpt
if [ -z "$port_vx" ] && [ ! -e "$HOME/agsbx/port_vx" ]; then
port_vx=$(shuf -i 10000-65535 -n 1)
echo "$port_vx" > "$HOME/agsbx/port_vx"
elif [ -n "$port_vx" ]; then
echo "$port_vx" > "$HOME/agsbx/port_vx"
fi
port_vx=$(cat "$HOME/agsbx/port_vx")
echo "Vless-xhttp-enc端口：$port_vx"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
    {
      "tag":"vless-xhttp",
      "listen": "::",
      "port": ${port_vx},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "${dekey}"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": {
          "host": "",
          "path": "${uuid}-vx",
          "mode": "auto"
        }
      },
        "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      }
    },
EOF
else
vxp=vxptargo
fi
if [ -n "$vwp" ]; then
vwp=vwpt
if [ -z "$port_vw" ] && [ ! -e "$HOME/agsbx/port_vw" ]; then
port_vw=$(shuf -i 10000-65535 -n 1)
echo "$port_vw" > "$HOME/agsbx/port_vw"
elif [ -n "$port_vw" ]; then
echo "$port_vw" > "$HOME/agsbx/port_vw"
fi
port_vw=$(cat "$HOME/agsbx/port_vw")
echo "Vless-ws-enc端口：$port_vw"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
cat >> "$HOME/agsbx/xr.json" <<EOF
    {
      "tag":"vless-ws",
      "listen": "::",
      "port": ${port_vw},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "${dekey}"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "${uuid}-vw"
        }
      },
        "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      }
    },
EOF
else
vwp=vwptargo
fi
if [ -n "$vlp" ]; then
vlp=vlpt
if [ -z "$port_vl_re" ] && [ ! -e "$HOME/agsbx/port_vl_re" ]; then
port_vl_re=$(shuf -i 10000-65535 -n 1)
echo "$port_vl_re" > "$HOME/agsbx/port_vl_re"
elif [ -n "$port_vl_re" ]; then
echo "$port_vl_re" > "$HOME/agsbx/port_vl_re"
fi
port_vl_re=$(cat "$HOME/agsbx/port_vl_re")
echo "Vless-tcp-reality-v端口：$port_vl_re"
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
            "tag":"reality-vision",
            "listen": "::",
            "port": $port_vl_re,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "fingerprint": "chrome",
                    "dest": "${ym_vl_re}:443",
                    "serverNames": [
                      "${ym_vl_re}"
                    ],
                    "privateKey": "$private_key_x",
                    "shortIds": ["$short_id_x"]
                }
            },
          "sniffing": {
          "enabled": true,
          "destOverride": ["http", "tls", "quic"],
          "metadataOnly": false
      }
    },  
EOF
else
vlp=vlptargo
fi
}

installsb(){
echo
echo "=========启用Sing-box内核========="
if [ ! -e "$HOME/agsbx/sing-box" ]; then
upsingbox
fi
cat > "$HOME/agsbx/sb.json" <<EOF
{
"log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
EOF
insuuid
if [ ! -f "$HOME/agsbx/SHA256.txt" ]; then
command -v openssl >/dev/null 2>&1 && openssl ecparam -genkey -name prime256v1 -out "$HOME/agsbx/private.key" >/dev/null 2>&1
command -v openssl >/dev/null 2>&1 && openssl req -new -x509 -days 36500 -key "$HOME/agsbx/private.key" -out "$HOME/agsbx/cert.crt" -subj "/CN=www.bing.com" >/dev/null 2>&1
#if [ ! -f "$HOME/agsbx/private.key" ]; then
#url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/private.key"; out="$HOME/agsbx/private.key"; (command -v curl>/dev/null 2>&1 && curl -Ls -o "$out" --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -q -O "$out" --tries=2 "$url")
#url="https://github.com/yonggekkk/argosbx/releases/download/argosbx/cert.crt"; out="$HOME/agsbx/cert.crt"; (command -v curl>/dev/null 2>&1 && curl -Ls -o "$out" --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -q -O "$out" --tries=2 "$url")
#echo "fc6dca8cfc4081102aa9655d0d4805c27d7266f605541d242ad66ad00a284a35" > "$HOME/agsbx/SHA256.txt"
#else
SHA256=$(openssl x509 -in $HOME/agsbx/cert.crt -outform DER | sha256sum | awk '{print $1}')
echo "$SHA256" > "$HOME/agsbx/SHA256.txt"
#fi
fi
if [ -n "$hyp" ]; then
hyp=hypt
if [ -z "$port_hy2" ] && [ ! -e "$HOME/agsbx/port_hy2" ]; then
port_hy2=$(shuf -i 10000-65535 -n 1)
echo "$port_hy2" > "$HOME/agsbx/port_hy2"
elif [ -n "$port_hy2" ]; then
echo "$port_hy2" > "$HOME/agsbx/port_hy2"
fi
port_hy2=$(cat "$HOME/agsbx/port_hy2")
echo "Hysteria2端口：$port_hy2"
cat >> "$HOME/agsbx/sb.json" <<EOF
    {
        "type": "hysteria2",
        "tag": "hy2-sb",
        "listen": "::",
        "listen_port": ${port_hy2},
        "users": [
            {
                "password": "${uuid}"
            }
        ],
        "ignore_client_bandwidth":false,
        "tls": {
            "enabled": true,
            "alpn": [
                "h3"
            ],
            "certificate_path": "$HOME/agsbx/cert.crt",
            "key_path": "$HOME/agsbx/private.key"
        }
    },
EOF
else
hyp=hyptargo
fi
if [ -n "$tup" ]; then
tup=tupt
if [ -z "$port_tu" ] && [ ! -e "$HOME/agsbx/port_tu" ]; then
port_tu=$(shuf -i 10000-65535 -n 1)
echo "$port_tu" > "$HOME/agsbx/port_tu"
elif [ -n "$port_tu" ]; then
echo "$port_tu" > "$HOME/agsbx/port_tu"
fi
port_tu=$(cat "$HOME/agsbx/port_tu")
echo "Tuic端口：$port_tu"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"tuic",
            "tag": "tuic5-sb",
            "listen": "::",
            "listen_port": ${port_tu},
            "users": [
                {
                    "uuid": "${uuid}",
                    "password": "${uuid}"
                }
            ],
            "congestion_control": "bbr",
            "tls":{
                "enabled": true,
                "alpn": [
                    "h3"
                ],
                "certificate_path": "$HOME/agsbx/cert.crt",
                "key_path": "$HOME/agsbx/private.key"
            }
        },
EOF
else
tup=tuptargo
fi
if [ -n "$anp" ]; then
anp=anpt
if [ -z "$port_an" ] && [ ! -e "$HOME/agsbx/port_an" ]; then
port_an=$(shuf -i 10000-65535 -n 1)
echo "$port_an" > "$HOME/agsbx/port_an"
elif [ -n "$port_an" ]; then
echo "$port_an" > "$HOME/agsbx/port_an"
fi
port_an=$(cat "$HOME/agsbx/port_an")
echo "Anytls端口：$port_an"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"anytls",
            "tag":"anytls-sb",
            "listen":"::",
            "listen_port":${port_an},
            "users":[
                {
                  "password":"${uuid}"
                }
            ],
            "padding_scheme":[],
            "tls":{
                "enabled": true,
                "certificate_path": "$HOME/agsbx/cert.crt",
                "key_path": "$HOME/agsbx/private.key"
            }
        },
EOF
else
anp=anptargo
fi
if [ -n "$arp" ]; then
arp=arpt
if [ -z "$ym_vl_re" ]; then
ym_vl_re=apple.com
fi
echo "$ym_vl_re" > "$HOME/agsbx/ym_vl_re"
echo "Reality域名：$ym_vl_re"
mkdir -p "$HOME/agsbx/sbk"
if [ ! -e "$HOME/agsbx/sbk/private_key" ]; then
key_pair=$("$HOME/agsbx/sing-box" generate reality-keypair)
private_key=$(echo "$key_pair" | awk '/PrivateKey/ {print $2}' | tr -d '"')
public_key=$(echo "$key_pair" | awk '/PublicKey/ {print $2}' | tr -d '"')
short_id=$("$HOME/agsbx/sing-box" generate rand --hex 4)
echo "$private_key" > "$HOME/agsbx/sbk/private_key"
echo "$public_key" > "$HOME/agsbx/sbk/public_key"
echo "$short_id" > "$HOME/agsbx/sbk/short_id"
fi
private_key_s=$(cat "$HOME/agsbx/sbk/private_key")
public_key_s=$(cat "$HOME/agsbx/sbk/public_key")
short_id_s=$(cat "$HOME/agsbx/sbk/short_id")
if [ -z "$port_ar" ] && [ ! -e "$HOME/agsbx/port_ar" ]; then
port_ar=$(shuf -i 10000-65535 -n 1)
echo "$port_ar" > "$HOME/agsbx/port_ar"
elif [ -n "$port_ar" ]; then
echo "$port_ar" > "$HOME/agsbx/port_ar"
fi
port_ar=$(cat "$HOME/agsbx/port_ar")
echo "Any-Reality端口：$port_ar"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type":"anytls",
            "tag":"anyreality-sb",
            "listen":"::",
            "listen_port":${port_ar},
            "users":[
                {
                  "password":"${uuid}"
                }
            ],
            "padding_scheme":[],
            "tls": {
            "enabled": true,
            "server_name": "${ym_vl_re}",
             "reality": {
              "enabled": true,
              "handshake": {
              "server": "${ym_vl_re}",
              "server_port": 443
             },
             "private_key": "$private_key_s",
             "short_id": ["$short_id_s"]
            }
          }
        },
EOF
else
arp=arptargo
fi
if [ -n "$ssp" ]; then
ssp=sspt
if [ ! -e "$HOME/agsbx/sskey" ]; then
sskey=$("$HOME/agsbx/sing-box" generate rand 16 --base64)
echo "$sskey" > "$HOME/agsbx/sskey"
fi
if [ -z "$port_ss" ] && [ ! -e "$HOME/agsbx/port_ss" ]; then
port_ss=$(shuf -i 10000-65535 -n 1)
echo "$port_ss" > "$HOME/agsbx/port_ss"
elif [ -n "$port_ss" ]; then
echo "$port_ss" > "$HOME/agsbx/port_ss"
fi
sskey=$(cat "$HOME/agsbx/sskey")
port_ss=$(cat "$HOME/agsbx/port_ss")
echo "Shadowsocks-2022端口：$port_ss"
cat >> "$HOME/agsbx/sb.json" <<EOF
        {
            "type": "shadowsocks",
            "tag":"ss-2022",
            "listen": "::",
            "listen_port": $port_ss,
            "method": "2022-blake3-aes-128-gcm",
            "password": "$sskey"
    },  
EOF
else
ssp=ssptargo
fi
}

xrsbvm(){
if [ -n "$vmp" ]; then
vmp=vmpt
if [ -z "$port_vm_ws" ] && [ ! -e "$HOME/agsbx/port_vm_ws" ]; then
port_vm_ws=$(shuf -i 10000-65535 -n 1)
echo "$port_vm_ws" > "$HOME/agsbx/port_vm_ws"
elif [ -n "$port_vm_ws" ]; then
echo "$port_vm_ws" > "$HOME/agsbx/port_vm_ws"
fi
port_vm_ws=$(cat "$HOME/agsbx/port_vm_ws")
echo "Vmess-ws端口：$port_vm_ws"
if [ -n "$cdnym" ]; then
echo "$cdnym" > "$HOME/agsbx/cdnym"
echo "80系CDN或者回源CDN的host域名 (确保IP已解析在CF域名)：$cdnym"
fi
if [ -e "$HOME/agsbx/xr.json" ]; then
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
            "tag": "vmess-xr",
            "listen": "::",
            "port": ${port_vm_ws},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                  "path": "${uuid}-vm"
            }
        },
            "sniffing": {
            "enabled": true,
            "destOverride": ["http", "tls", "quic"],
            "metadataOnly": false
            }
         }, 
EOF
else
cat >> "$HOME/agsbx/sb.json" <<EOF
{
        "type": "vmess",
        "tag": "vmess-sb",
        "listen": "::",
        "listen_port": ${port_vm_ws},
        "users": [
            {
                "uuid": "${uuid}",
                "alterId": 0
            }
        ],
        "transport": {
            "type": "ws",
            "path": "${uuid}-vm",
            "max_early_data":2048,
            "early_data_header_name": "Sec-WebSocket-Protocol"
        }
    },
EOF
fi
else
vmp=vmptargo
fi
}

xrsbso(){
if [ -n "$sop" ]; then
sop=sopt
if [ -z "$port_so" ] && [ ! -e "$HOME/agsbx/port_so" ]; then
port_so=$(shuf -i 10000-65535 -n 1)
echo "$port_so" > "$HOME/agsbx/port_so"
elif [ -n "$port_so" ]; then
echo "$port_so" > "$HOME/agsbx/port_so"
fi
port_so=$(cat "$HOME/agsbx/port_so")
echo "Socks5端口：$port_so"
if [ -e "$HOME/agsbx/xr.json" ]; then
cat >> "$HOME/agsbx/xr.json" <<EOF
        {
         "tag": "socks5-xr",
         "port": ${port_so},
         "listen": "::",
         "protocol": "socks",
         "settings": {
            "auth": "password",
             "accounts": [
               {
               "user": "${uuid}",
               "pass": "${uuid}"
               }
            ],
            "udp": true
          },
            "sniffing": {
            "enabled": true,
            "destOverride": ["http", "tls", "quic"],
            "metadataOnly": false
            }
         }, 
EOF
else
cat >> "$HOME/agsbx/sb.json" <<EOF
    {
      "tag": "socks5-sb",
      "type": "socks",
      "listen": "::",
      "listen_port": ${port_so},
      "users": [
      {
      "username": "${uuid}",
      "password": "${uuid}"
      }
     ]
    },
EOF
fi
else
sop=soptargo
fi
}

xrsbout(){
if [ -e "$HOME/agsbx/xr.json" ]; then
sed -i '${s/,\s*$//}' "$HOME/agsbx/xr.json"
cat >> "$HOME/agsbx/xr.json" <<EOF
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
      "domainStrategy":"${xryx}"
     }
    },
    {
      "tag": "x-warp-out",
      "protocol": "wireguard",
      "settings": {
        "secretKey": "${pvk}",
        "address": [
          "172.16.0.2/32",
          "${wpv6}/128"
        ],
        "peers": [
          {
            "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
            "allowedIPs": [
              "0.0.0.0/0",
              "::/0"
            ],
            "endpoint": "${xendip}:2408"
          }
        ],
        "reserved": ${res}
        }
    },
    {
      "tag":"warp-out",
      "protocol":"freedom",
        "settings":{
        "domainStrategy":"${wxryx}"
       },
       "proxySettings":{
       "tag":"x-warp-out"
     }
}
  ],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [
      {
        "type": "field",
        "ip": [ ${xip} ],
        "network": "tcp,udp",
        "outboundTag": "${x1outtag}"
      },
      {
        "type": "field",
        "network": "tcp,udp",
        "outboundTag": "${x2outtag}"
      }
    ]
  }
}
EOF
if pidof systemd >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/systemd/system/xr.service <<EOF
[Unit]
Description=xr service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/xray run -c /root/agsbx/xr.json
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable xr >/dev/null 2>&1
systemctl start xr >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/init.d/xray <<EOF
#!/sbin/openrc-run
description="xr service"
command="/root/agsbx/xray"
command_args="run -c /root/agsbx/xr.json"
command_background=yes
pidfile="/run/xray.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/xray >/dev/null 2>&1
rc-update add xray default >/dev/null 2>&1
rc-service xray start >/dev/null 2>&1
else
nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" >/dev/null 2>&1 &
fi
fi
if [ -e "$HOME/agsbx/sb.json" ]; then
sed -i '${s/,\s*$//}' "$HOME/agsbx/sb.json"
cat >> "$HOME/agsbx/sb.json" <<EOF
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "endpoints": [
    {
      "type": "wireguard",
      "tag": "warp-out",
      "address": [
        "172.16.0.2/32",
        "${wpv6}/128"
      ],
      "private_key": "${pvk}",
      "peers": [
        {
          "address": "${sendip}",
          "port": 2408,
          "public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
          "allowed_ips": [
            "0.0.0.0/0",
            "::/0"
          ],
          "reserved": $res
        }
      ]
    }
  ],
  "route": {
    "rules": [
       {
          "action": "sniff"
        },
       {
        "action": "resolve",
         "strategy": "${sbyx}"
       },
      {
        "ip_cidr": [ ${sip} ],         
        "outbound": "${s1outtag}"
      }
    ],
    "final": "${s2outtag}"
  }
}
EOF
if pidof systemd >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/systemd/system/sb.service <<EOF
[Unit]
Description=sb service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/sing-box run -c /root/agsbx/sb.json
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable sb >/dev/null 2>&1
systemctl start sb >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/init.d/sing-box <<EOF
#!/sbin/openrc-run
description="sb service"
command="/root/agsbx/sing-box"
command_args="run -c /root/agsbx/sb.json"
command_background=yes
pidfile="/run/sing-box.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/sing-box >/dev/null 2>&1
rc-update add sing-box default >/dev/null 2>&1
rc-service sing-box start >/dev/null 2>&1
else
nohup "$HOME/agsbx/sing-box" run -c "$HOME/agsbx/sb.json" >/dev/null 2>&1 &
fi
fi
}
ins(){
if legacy_selected; then
if [ "$hyp" != yes ] && [ "$tup" != yes ] && [ "$anp" != yes ] && [ "$arp" != yes ] && [ "$ssp" != yes ]; then
installxray
xrsbvm
xrsbso
warpsx
xrsbout
hyp="hyptargo"; tup="tuptargo"; anp="anptargo"; arp="arptargo"; ssp="ssptargo"
elif [ "$xhp" != yes ] && [ "$vlp" != yes ] && [ "$vxp" != yes ] && [ "$vwp" != yes ]; then
installsb
xrsbvm
xrsbso
warpsx
xrsbout
xhp="xhptargo"; vlp="vlptargo"; vxp="vxptargo"; vwp="vwptargo"
else
installsb
installxray
xrsbvm
xrsbso
warpsx
xrsbout
fi
fi
if mieru_selected; then
installmita || exit 1
fi
if [ -n "$argo" ] && [ -z "$vmag" ]; then
echo "提示：Argo 只支持现有 WebSocket 协议，Mieru 不会接入 Argo/CDN"
fi
if [ -n "$argo" ] && [ -n "$vmag" ]; then
echo
echo "=========启用Cloudflared-argo内核========="
if [ ! -e "$HOME/agsbx/cloudflared" ]; then
argocore=$({ command -v curl >/dev/null 2>&1 && curl -Ls https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared || wget -qO- https://data.jsdelivr.com/v1/package/gh/cloudflare/cloudflared; } | grep -Eo '"[0-9.]+"' | sed -n 1p | tr -d '",')
echo "下载Cloudflared-argo最新正式版内核：$argocore"
url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$cpu"; out="$HOME/agsbx/cloudflared"; (command -v curl>/dev/null 2>&1 && curl -Lo "$out" -# --retry 2 "$url") || (command -v wget>/dev/null 2>&1 && timeout 3 wget -O "$out" --tries=2 "$url")
chmod +x "$HOME/agsbx/cloudflared"
fi
if [ "$argo" = "vmpt" ]; then argoport=$(cat "$HOME/agsbx/port_vm_ws" 2>/dev/null); echo "Vmess" > "$HOME/agsbx/vlvm"; elif [ "$argo" = "vwpt" ]; then argoport=$(cat "$HOME/agsbx/port_vw" 2>/dev/null); echo "Vless" > "$HOME/agsbx/vlvm"; fi; echo "$argoport" > "$HOME/agsbx/argoport.log"
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
argoname='固定'
if pidof systemd >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/systemd/system/argo.service <<EOF
[Unit]
Description=argo service
After=network.target
[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/root/agsbx/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "${ARGO_AUTH}"
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >/dev/null 2>&1
systemctl enable argo >/dev/null 2>&1
systemctl start argo >/dev/null 2>&1
elif command -v rc-service >/dev/null 2>&1 && [ "$EUID" -eq 0 ]; then
cat > /etc/init.d/argo <<EOF
#!/sbin/openrc-run
description="argo service"
command="/root/agsbx/cloudflared tunnel"
command_args="--no-autoupdate --edge-ip-version auto --protocol http2 run --token ${ARGO_AUTH}"
pidfile="/run/argo.pid"
command_background="yes"
depend() {
need net
}
EOF
chmod +x /etc/init.d/argo >/dev/null 2>&1
rc-update add argo default >/dev/null 2>&1
rc-service argo start >/dev/null 2>&1
else
nohup "$HOME/agsbx/cloudflared" tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "${ARGO_AUTH}" >/dev/null 2>&1 &
fi
echo "${ARGO_DOMAIN}" > "$HOME/agsbx/sbargoym.log"
echo "${ARGO_AUTH}" > "$HOME/agsbx/sbargotoken.log"
else
argoname='临时'
nohup "$HOME/agsbx/cloudflared" tunnel --url http://localhost:$(cat $HOME/agsbx/argoport.log) --edge-ip-version auto --no-autoupdate --protocol http2 > $HOME/agsbx/argo.log 2>&1 &
fi
echo "申请Argo$argoname隧道中……请稍等"
sleep 15
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
argodomain=$(cat "$HOME/agsbx/sbargoym.log" 2>/dev/null)
else
argodomain=$(grep -a trycloudflare.com "$HOME/agsbx/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
fi
if [ -n "${argodomain}" ]; then
echo "Argo$argoname隧道申请成功"
else
echo "Argo$argoname隧道申请失败，请稍后再试"
fi
fi
sleep 5
echo
if configured_cores_running; then
[ -f "$HOME/.bashrc" ] || touch "$HOME/.bashrc"
clean_agsbx_bashrc
ensure_agsbx_path
SCRIPT_PATH="$HOME/bin/agsbx"
mkdir -p "$HOME/bin"
(command -v curl >/dev/null 2>&1 && curl -sL "$agsbxurl" -o "$SCRIPT_PATH") || (command -v wget >/dev/null 2>&1 && wget -qO "$SCRIPT_PATH" "$agsbxurl")
chmod +x "$SCRIPT_PATH"
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
cat >> "$HOME/.bashrc" <<'AGSHEALTH'
# >>> ARGOSBX HEALTHCHECK >>>
argosbx_healthcheck(){
need_res=no
for item in "xr.json:xray" "sb.json:sing-box"; do
cfg=${item%%:*}
core=${item#*:}
if [ -f "$HOME/agsbx/$cfg" ]; then
found=no
for exe in /proc/[0-9]*/exe; do
[ -L "$exe" ] || continue
[ "$(readlink -f "$exe" 2>/dev/null)" = "$(readlink -f "$HOME/agsbx/$core" 2>/dev/null)" ] && found=yes
done
[ "$found" = yes ] || need_res=yes
fi
done
if [ -f "$HOME/agsbx/mita.json" ] && ! env MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json" MITA_UDS_PATH="$HOME/agsbx/mita.sock" MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true "$HOME/agsbx/mita" status 2>/dev/null | grep -q 'status is "RUNNING"'; then
need_res=yes
fi
[ "$need_res" = yes ] && "$HOME/bin/agsbx" res >/dev/null 2>&1 || true
}
argosbx_healthcheck
unset -f argosbx_healthcheck
# <<< ARGOSBX HEALTHCHECK <<<
AGSHEALTH
fi
grep -qxF 'source ~/.bashrc' ~/.bash_profile 2>/dev/null || echo 'source ~/.bashrc' >> ~/.bash_profile
. ~/.bashrc 2>/dev/null
crontab -l > /tmp/crontab.tmp 2>/dev/null
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp
if [ -f "$HOME/agsbx/sb.json" ]; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/sing-box run -c $HOME/agsbx/sb.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
if [ -f "$HOME/agsbx/xr.json" ]; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/xray run -c $HOME/agsbx/xr.json >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
if [ -f "$HOME/agsbx/mita.json" ]; then
echo '@reboot sleep 10 && /bin/sh -c "nohup env MITA_CONFIG_JSON_FILE=$HOME/agsbx/mita.json MITA_UDS_PATH=$HOME/agsbx/mita.sock MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true $HOME/agsbx/mita run >$HOME/agsbx/mita.log 2>&1 &"' >> /tmp/crontab.tmp
fi
fi
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp
if [ -n "$argo" ] && [ -n "$vmag" ]; then
if [ -n "${ARGO_DOMAIN}" ] && [ -n "${ARGO_AUTH}" ]; then
if ! pidof systemd >/dev/null 2>&1 && ! command -v rc-service >/dev/null 2>&1; then
echo '@reboot sleep 10 && /bin/sh -c "nohup $HOME/agsbx/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token $(cat $HOME/agsbx/sbargotoken.log 2>/dev/null) >/dev/null 2>&1 &"' >> /tmp/crontab.tmp
fi
else
if command -v apk >/dev/null 2>&1; then
cat > /etc/local.d/alpineargosbx.start <<EOF
#!/bin/bash
sleep 10
nohup $HOME/agsbx/cloudflared tunnel --url http://localhost:\$(cat $HOME/agsbx/argoport.log) --edge-ip-version auto --no-autoupdate --protocol http2 > $HOME/agsbx/argo.log 2>&1 &
sleep 10
HOME="$HOME" $HOME/bin/agsbx list >/dev/null 2>&1
EOF
chmod +x /etc/local.d/alpineargosbx.start
rc-update add local default >/dev/null 2>&1
else
echo '@reboot sleep 10 && /bin/bash -c "nohup $HOME/agsbx/cloudflared tunnel --url http://localhost:$(cat $HOME/agsbx/argoport.log) --edge-ip-version auto --no-autoupdate --protocol http2 > $HOME/agsbx/argo.log 2>&1 & sleep 10 && bash $HOME/bin/agsbx list >/dev/null 2>&1"' >> /tmp/crontab.tmp
fi
fi
fi
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp
echo "Argosbx脚本进程启动成功，安装完毕" && sleep 2
else
echo "Argosbx脚本进程未启动，安装失败" && exit
fi
if [ -n "$cfip" ]; then
set -- $cfip
cdnip1="$1"
cdnip2="$2"
echo "$cdnip1" > "$HOME/agsbx/cdnip1"
echo "$cdnip2" > "$HOME/agsbx/cdnip2"
else
if [ -s "$HOME/agsbx/cdnip1" ] && [ -s "$HOME/agsbx/cdnip2" ]; then
cdnip1=$(cat "$HOME/agsbx/cdnip1")
cdnip2=$(cat "$HOME/agsbx/cdnip2")
else
cdnip1="yg1.ygkkk.dpdns.org"
cdnip2="yg6.ygkkk.dpdns.org"
echo "$cdnip1" > "$HOME/agsbx/cdnip1"
echo "$cdnip2" > "$HOME/agsbx/cdnip2"
fi
fi
}
argosbxstatus(){
echo "=========当前四大内核运行状态========="
if is_exe_running "$HOME/agsbx/sing-box"; then
echo "Sing-box (版本V$("$HOME/agsbx/sing-box" version 2>/dev/null | awk '/version/{print $NF}'))：运行中"
else
echo "Sing-box：未启用"
fi
if is_exe_running "$HOME/agsbx/xray"; then
echo "Xray (版本V$("$HOME/agsbx/xray" version 2>/dev/null | awk '/^Xray/{print $2}'))：运行中"
else
echo "Xray：未启用"
fi
if is_exe_running "$HOME/agsbx/cloudflared"; then
echo "Argo (版本V$("$HOME/agsbx/cloudflared" version 2>/dev/null | awk '{print $3}'))：运行中"
else
echo "Argo：未启用"
fi
if mita_running; then
echo "Mita (Mieru $MIERU_VERSION)：运行中"
elif [ -f "$HOME/agsbx/mita.json" ]; then
echo "Mita (Mieru $MIERU_VERSION)：异常或未运行"
else
echo "Mita：未启用"
fi
}
cip(){
ipbest(){
serip=$( (command -v curl >/dev/null 2>&1 && (curl -s4m5 -k "$v46url" 2>/dev/null || curl -s6m5 -k "$v46url" 2>/dev/null) ) || (command -v wget >/dev/null 2>&1 && (timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null || timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null) ) )
if echo "$serip" | grep -q ':'; then
server_ip="[$serip]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
else
server_ip="$serip"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
}
ipchange(){
v4v6
if [ -z "$v4" ]; then
vps_ipv4='无IPV4'
vps_ipv6="$v6"
location="$v6dq"
elif [ -n "$v4" ] && [ -n "$v6" ]; then
vps_ipv4="$v4"
vps_ipv6="$v6"
location="$v4dq"
else
vps_ipv4="$v4"
vps_ipv6='无IPV6'
location="$v4dq"
fi
if echo "$v6" | grep -q '^2a09'; then
w6="【WARP】"
fi
if echo "$v4" | grep -q '^104.28'; then
w4="【WARP】"
fi
echo
argosbxstatus
echo
echo "=========当前服务器本地IP情况========="
echo "本地IPV4地址：$vps_ipv4 $w4"
echo "本地IPV6地址：$vps_ipv6 $w6"
echo "服务器地区：$location"
echo
sleep 2
if [ "$ippz" = "4" ]; then
if [ -z "$v4" ]; then
ipbest
else
server_ip="$v4"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
elif [ "$ippz" = "6" ]; then
if [ -z "$v6" ]; then
ipbest
else
server_ip="[$v6]"
echo "$server_ip" > "$HOME/agsbx/server_ip.log"
fi
else
ipbest
fi
}
ipchange
rm -f "$HOME/agsbx/jhsub.txt"
uuid=$(cat "$HOME/agsbx/uuid" 2>/dev/null)
legacy_output=no
if [ -f "$HOME/agsbx/xr.json" ] || [ -f "$HOME/agsbx/sb.json" ]; then legacy_output=yes; fi
server_ip=$(cat "$HOME/agsbx/server_ip.log")
sxname=$(cat "$HOME/agsbx/name" 2>/dev/null)
xvvmcdnym=$(cat "$HOME/agsbx/cdnym" 2>/dev/null)
cdnip1=$(cat "$HOME/agsbx/cdnip1" 2>/dev/null)
cdnip2=$(cat "$HOME/agsbx/cdnip2" 2>/dev/null)
echo "*********************************************************"
echo "*********************************************************"
echo "Argosbx脚本输出节点配置如下："
echo
case "$server_ip" in
104.28*|\[2a09*) echo "检测到有WARP的IP作为客户端地址 (104.28或者2a09开头的IP)，请把客户端地址上的WARP的IP手动更换为VPS本地IPV4或者IPV6地址" && sleep 3 ;;
esac
echo
if [ -f "$HOME/agsbx/mita.json" ]; then
generate_mieru_links || echo "警告：Mieru 分享链接生成失败，旧 mieru.txt（如有）保持不变" >&2
fi
ym_vl_re=$(cat "$HOME/agsbx/ym_vl_re" 2>/dev/null)
cfipsj() { echo $((RANDOM % 13 + 1)); }
if [ -e "$HOME/agsbx/xray" ]; then
private_key_x=$(cat "$HOME/agsbx/xrk/private_key" 2>/dev/null)
public_key_x=$(cat "$HOME/agsbx/xrk/public_key" 2>/dev/null)
short_id_x=$(cat "$HOME/agsbx/xrk/short_id" 2>/dev/null)
enkey=$(cat "$HOME/agsbx/xrk/enkey" 2>/dev/null)
fi
if [ -e "$HOME/agsbx/sing-box" ]; then
private_key_s=$(cat "$HOME/agsbx/sbk/private_key" 2>/dev/null)
public_key_s=$(cat "$HOME/agsbx/sbk/public_key" 2>/dev/null)
short_id_s=$(cat "$HOME/agsbx/sbk/short_id" 2>/dev/null)
sskey=$(cat "$HOME/agsbx/sskey" 2>/dev/null)
fi
if grep xhttp-reality "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp-reality-enc 】支持ENC加密，节点信息如下："
port_xh=$(cat "$HOME/agsbx/port_xh")
vl_xh_link="vless://$uuid@$server_ip:$port_xh?encryption=$enkey&flow=xtls-rprx-vision&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=xhttp&path=$uuid-xh&mode=auto#${sxname}vl-xhttp-reality-enc-$hostname"
echo "$vl_xh_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_xh_link"
echo
fi
if grep vless-xhttp "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-xhttp-enc 】支持ENC加密，节点信息如下："
port_vx=$(cat "$HOME/agsbx/port_vx")
vl_vx_link="vless://$uuid@$server_ip:$port_vx?encryption=$enkey&flow=xtls-rprx-vision&type=xhttp&path=$uuid-vx&mode=auto#${sxname}vl-xhttp-enc-$hostname"
echo "$vl_vx_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_vx_link"
echo
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vless-xhttp-ecn-cdn 】支持ENC加密，节点信息如下："
echo "注：默认地址 yg数字.ygkkk.dpdns.org 可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
vl_vx_cdn_link="vless://$uuid@yg$(cfipsj).ygkkk.dpdns.org:$port_vx?encryption=$enkey&flow=xtls-rprx-vision&type=xhttp&host=$xvvmcdnym&path=$uuid-vx&mode=auto#${sxname}vl-xhttp-enc-cdn-$hostname"
echo "$vl_vx_cdn_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_vx_cdn_link"
echo
fi
fi
if grep vless-ws "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-ws-enc 】支持ENC加密，节点信息如下："
port_vw=$(cat "$HOME/agsbx/port_vw")
vl_vw_link="vless://$uuid@$server_ip:$port_vw?encryption=$enkey&flow=xtls-rprx-vision&type=ws&path=$uuid-vw#${sxname}vl-ws-enc-$hostname"
echo "$vl_vw_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_vw_link"
echo
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vless-ws-enc-cdn 】支持ENC加密，节点信息如下："
echo "注：默认地址 yg数字.ygkkk.dpdns.org 可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
vl_vw_cdn_link="vless://$uuid@yg$(cfipsj).ygkkk.dpdns.org:$port_vw?encryption=$enkey&flow=xtls-rprx-vision&type=ws&host=$xvvmcdnym&path=$uuid-vw#${sxname}vl-ws-enc-cdn-$hostname"
echo "$vl_vw_cdn_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_vw_cdn_link"
echo
fi
fi
if grep reality-vision "$HOME/agsbx/xr.json" >/dev/null 2>&1; then
echo "💣【 Vless-tcp-reality-vision 】节点信息如下："
port_vl_re=$(cat "$HOME/agsbx/port_vl_re")
vl_link="vless://$uuid@$server_ip:$port_vl_re?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_x&sid=$short_id_x&type=tcp&headerType=none#${sxname}vl-reality-vision-$hostname"
echo "$vl_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vl_link"
echo
sbvlpt(){
cat <<EOF
    {
      "type": "vless",
      "tag": "${sxname}vless-$hostname",
      "server": "$server_ip",
      "server_port": $port_vl_re,
      "uuid": "$uuid",
      "flow": "xtls-rprx-vision",
      "tls": {
        "enabled": true,
        "server_name": "$ym_vl_re",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
      "reality": {
          "enabled": true,
          "public_key": "$public_key_x",
          "short_id": "$short_id_x"
        }
      }
    },
EOF
}
sbvlpt1(){
echo "\"${sxname}vless-$hostname\","
}
clvlpt(){
cat <<EOF
- name: ${sxname}vless-reality-vision-$hostname               
  type: vless
  server: $server_ip                          
  port: $port_vl_re                                
  uuid: $uuid   
  network: tcp
  udp: true
  tls: true
  flow: xtls-rprx-vision
  servername: $ym_vl_re                 
  reality-opts: 
    public-key: $public_key_x    
    short-id: $short_id_x                      
  client-fingerprint: chrome
EOF
}
clvlpt1(){
echo "- ${sxname}vless-reality-vision-$hostname"
}
fi
if grep ss-2022 "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Shadowsocks-2022 】节点信息如下："
port_ss=$(cat "$HOME/agsbx/port_ss")
ss_link="ss://$(echo -n "2022-blake3-aes-128-gcm:$sskey@$server_ip:$port_ss" | base64 -w0)#${sxname}Shadowsocks-2022-$hostname"
echo "$ss_link" >> "$HOME/agsbx/jhsub.txt"
echo "$ss_link"
echo
sbsspt(){
cat <<EOF
{
       "type": "shadowsocks",
       "tag": "${sxname}Shadowsocks-2022-$hostname",
       "server": "$server_ip",
       "server_port": $port_ss,
       "method": "2022-blake3-aes-128-gcm",
       "password": "$sskey",
       "udp_over_tcp": {
        "enabled": true,
        "version": 2
      }
     },
EOF
}
sbsspt1(){
echo "\"${sxname}Shadowsocks-2022-$hostname\","
}
clsspt(){
cat <<EOF
- name: "${sxname}Shadowsocks-2022-$hostname"
  type: ss
  server: $server_ip
  port: $port_ss
  cipher: 2022-blake3-aes-128-gcm
  password: "$sskey"
  udp: true
  udp-over-tcp: true
  udp-over-tcp-version: 2
EOF
}
clsspt1(){
echo "- ${sxname}Shadowsocks-2022-$hostname"
}
fi
if grep vmess-xr "$HOME/agsbx/xr.json" >/dev/null 2>&1 || grep vmess-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Vmess-ws 】节点信息如下："
port_vm_ws=$(cat "$HOME/agsbx/port_vm_ws")
vm_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vm-ws-$hostname\", \"add\": \"$server_ip\", \"port\": \"$port_vm_ws\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"www.bing.com\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vm_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vm_link"
echo
sbvmpt(){
cat <<EOF
{
            "server": "$server_ip",
            "server_port": $port_vm_ws,
            "tag": "${sxname}vmess-$hostname",
            "tls": {
                "enabled": false,
                "server_name": "www.bing.com",
                "insecure": false,
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                }
            },
            "packet_encoding": "packetaddr",
            "transport": {
                "headers": {
                    "Host": [
                        "www.bing.com"
                    ]
                },
                "path": "$uuid-vm",
                "type": "ws"
            },
            "type": "vmess",
            "security": "auto",
            "uuid": "$uuid"
        },
EOF
}
sbvmpt1(){
echo "\"${sxname}vmess-$hostname\","
}
clvmpt(){
cat <<EOF
- name: ${sxname}vmess-ws-$hostname                         
  type: vmess
  server: $server_ip                        
  port: $port_vm_ws                                     
  uuid: $uuid       
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  network: ws
  servername: www.bing.com                    
  ws-opts:
    path: "$uuid-vm"                             
    headers:
      Host: www.bing.com
EOF
}
clvmpt1(){
echo "- ${sxname}vmess-ws-$hostname"
}
if [ -f "$HOME/agsbx/cdnym" ]; then
echo "💣【 Vmess-ws-cdn 】节点信息如下："
echo "注：默认地址 yg数字.ygkkk.dpdns.org 可自行更换优选IP域名，如是回源端口需手动修改443或者80系端口"
vm_cdn_link="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vm-ws-cdn-$hostname\", \"add\": \"yg$(cfipsj).ygkkk.dpdns.org\", \"port\": \"$port_vm_ws\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$xvvmcdnym\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vm_cdn_link" >> "$HOME/agsbx/jhsub.txt"
echo "$vm_cdn_link"
echo
fi
fi
if grep anytls-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 AnyTLS 】节点信息如下："
port_an=$(cat "$HOME/agsbx/port_an")
an_link="anytls://$uuid@$server_ip:$port_an?insecure=1&allowInsecure=1#${sxname}anytls-$hostname"
echo "$an_link" >> "$HOME/agsbx/jhsub.txt"
echo "$an_link"
echo
sbanpt(){
cat <<EOF
         {
            "type": "anytls",
            "tag": "${sxname}anytls-$hostname",
            "server": "$server_ip",
            "server_port": $port_an,
            "password": "$uuid",
            "idle_session_check_interval": "30s",
            "idle_session_timeout": "30s",
            "min_idle_session": 5,
            "tls": {
                "enabled": true,
                "insecure": true,
                "server_name": "www.bing.com"
            }
         },
EOF
}
sbanpt1(){
echo "\"${sxname}anytls-$hostname\","
}
clanpt(){
cat <<EOF
- name: ${sxname}anytls-$hostname
  type: anytls
  server: $server_ip
  port: $port_an
  password: $uuid
  client-fingerprint: chrome
  udp: true
  idle-session-check-interval: 30
  idle-session-timeout: 30
  sni: www.bing.com
  skip-cert-verify: true
EOF
}
clanpt1(){
echo "- ${sxname}anytls-$hostname"
}
fi
if grep anyreality-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Any-Reality 】节点信息如下："
port_ar=$(cat "$HOME/agsbx/port_ar")
ar_link="anytls://$uuid@$server_ip:$port_ar?security=reality&sni=$ym_vl_re&fp=chrome&pbk=$public_key_s&sid=$short_id_s&type=tcp&headerType=none#${sxname}any-reality-$hostname"
echo "$ar_link" >> "$HOME/agsbx/jhsub.txt"
echo "$ar_link"
echo
sbarpt(){
cat <<EOF
    {
        "type": "anytls",
        "tag": "${sxname}any-reality-$hostname",
        "server": "$server_ip",
        "server_port": $port_ar,
        "password": "$uuid",
        "idle_session_check_interval": "30s",
        "idle_session_timeout": "30s",
        "min_idle_session": 5,
        "tls": {
        "enabled": true,
        "server_name": "$ym_vl_re",
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
      "reality": {
          "enabled": true,
          "public_key": "$public_key_s",
          "short_id": "$short_id_s"
        }
      }
         },
EOF
}
sbarpt1(){
echo "\"${sxname}any-reality-$hostname\","
}
fi
if grep hy2-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Hysteria2 】节点信息如下："
SHA256=$(cat "$HOME/agsbx/SHA256.txt")
port_hy2=$(cat "$HOME/agsbx/port_hy2")
hy2_ports=$(iptables -t nat -nL --line 2>/dev/null | grep -w "$port_hy2" | awk '{print $8}' | sed 's/dpts://; s/dpt://' | tr '\n' ',' | sed 's/,$//')
if [ -n "$hy2_ports" ] || [ -n "$hyjpt" ]; then
echo "Hysteria2跳跃端口已开启：$hy2_ports"
cmhy2pt=$(echo $hy2_ports | tr ':' '-')
hyps="&mport=$cmhy2pt"
sbhy2pt=$(echo "$hy2_ports" | grep -o '[0-9]\+:[0-9]\+' | sed 's/.*/"&"/' | paste -sd,)
sbhy2ports(){
    cat <<EOF
  "server_ports": [ $sbhy2pt ],
EOF
}
else
hyps=
fi
#hy2_link="hysteria2://$uuid@$server_ip:$port_hy2?security=tls&alpn=h3&insecure=1&allowInsecure=1$hyps&sni=www.bing.com#${sxname}hy2-$hostname"
hy2_link="hysteria2://$uuid@$server_ip:$port_hy2?security=tls&alpn=h3&insecure=0&allowInsecure=0$hyps&sni=www.bing.com&pinSHA256=$SHA256#${sxname}hy2-$hostname"
echo "$hy2_link" >> "$HOME/agsbx/jhsub.txt"
echo "$hy2_link"
echo
sbhypt(){
cat <<EOF
    {
        "type": "hysteria2",
        "tag": "${sxname}hy2-$hostname",
        "server": "$server_ip",
        "server_port": $port_hy2,
$(sbhy2ports 2>/dev/null)
        "password": "$uuid",
        "tls": {
            "enabled": true,
            "server_name": "www.bing.com",
            "insecure": true,
            "alpn": [
                "h3"
            ]
        }
    },
EOF
}
sbhypt1(){
echo "\"${sxname}hy2-$hostname\","
}
clhypt(){
cat <<EOF
- name: ${sxname}hysteria2-$hostname                            
  type: hysteria2                                      
  server: $server_ip                              
  port: $port_hy2
  ports: $cmhy2pt
  password: $uuid                          
  alpn:
    - h3
  sni: www.bing.com                               
  skip-cert-verify: true
  fast-open: true
EOF
}
clhypt1(){
echo "- ${sxname}hysteria2-$hostname"
}
fi
if grep tuic5-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Tuic 】节点信息如下："
port_tu=$(cat "$HOME/agsbx/port_tu")
tuic5_link="tuic://$uuid:$uuid@$server_ip:$port_tu?congestion_control=bbr&udp_relay_mode=native&alpn=h3&sni=www.bing.com&insecure=1&allowInsecure=1&allow_insecure=1#${sxname}tuic-$hostname"
echo "$tuic5_link" >> "$HOME/agsbx/jhsub.txt"
echo "$tuic5_link"
echo
sbtupt(){
cat <<EOF
        {
            "type":"tuic",
            "tag": "${sxname}tuic5-$hostname",
            "server": "$server_ip",
            "server_port": $port_tu,
            "uuid": "$uuid",
            "password": "$uuid",
            "congestion_control": "bbr",
            "udp_relay_mode": "native",
            "udp_over_stream": false,
            "zero_rtt_handshake": false,
            "heartbeat": "10s",
            "tls":{
                "enabled": true,
                "server_name": "www.bing.com",
                "insecure": true,
                "alpn": [
                    "h3"
                ]
            }
        },
EOF
}
sbtupt1(){
echo "\"${sxname}tuic5-$hostname\","
}
cltupt(){
cat <<EOF
- name: ${sxname}tuic5-$hostname                            
  server: $server_ip                      
  port: $port_tu                                    
  type: tuic
  uuid: $uuid       
  password: $uuid   
  alpn: [h3]
  disable-sni: true
  reduce-rtt: true
  udp-relay-mode: native
  congestion-controller: bbr
  sni: www.bing.com                                
  skip-cert-verify: true
EOF
}
cltupt1(){
echo "- ${sxname}tuic5-$hostname"
}
fi
if grep socks5-xr "$HOME/agsbx/xr.json" >/dev/null 2>&1 || grep socks5-sb "$HOME/agsbx/sb.json" >/dev/null 2>&1; then
echo "💣【 Socks5 】客户端信息如下："
port_so=$(cat "$HOME/agsbx/port_so")
echo "请配合其他应用内置代理使用，勿做节点直接使用"
echo "客户端地址：$server_ip"
echo "客户端端口：$port_so"
echo "客户端用户名：$uuid"
echo "客户端密码：$uuid"
echo
fi
argodomain=$(cat "$HOME/agsbx/sbargoym.log" 2>/dev/null)
[ -z "$argodomain" ] && argodomain=$(grep -a trycloudflare.com "$HOME/agsbx/argo.log" 2>/dev/null | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
if [ -n "$argodomain" ]; then
vlvm=$(cat $HOME/agsbx/vlvm 2>/dev/null)
if [ "$vlvm" = "Vmess" ]; then
vmatls_link1="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-443\", \"add\": \"$cdnip1\", \"port\": \"443\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link1" >> "$HOME/agsbx/jhsub.txt"
vmatls_link2="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-8443\", \"add\": \"yg2.ygkkk.dpdns.org\", \"port\": \"8443\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link2" >> "$HOME/agsbx/jhsub.txt"
vmatls_link3="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-2053\", \"add\": \"yg3.ygkkk.dpdns.org\", \"port\": \"2053\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link3" >> "$HOME/agsbx/jhsub.txt"
vmatls_link4="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-2083\", \"add\": \"yg4.ygkkk.dpdns.org\", \"port\": \"2083\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link4" >> "$HOME/agsbx/jhsub.txt"
vmatls_link5="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-2087\", \"add\": \"yg5.ygkkk.dpdns.org\", \"port\": \"2087\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link5" >> "$HOME/agsbx/jhsub.txt"
vmatls_link6="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-tls-argo-$hostname-2096\", \"add\": \"[2606:4700::0]\", \"port\": \"2096\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"tls\", \"sni\": \"$argodomain\", \"alpn\": \"\", \"fp\": \"chrome\"}" | base64 -w0)"
echo "$vmatls_link6" >> "$HOME/agsbx/jhsub.txt"
vma_link7="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-80\", \"add\": \"$cdnip2\", \"port\": \"80\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link7" >> "$HOME/agsbx/jhsub.txt"
vma_link8="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-8080\", \"add\": \"yg7.ygkkk.dpdns.org\", \"port\": \"8080\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link8" >> "$HOME/agsbx/jhsub.txt"
vma_link9="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-8880\", \"add\": \"yg8.ygkkk.dpdns.org\", \"port\": \"8880\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link9" >> "$HOME/agsbx/jhsub.txt"
vma_link10="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-2052\", \"add\": \"yg9.ygkkk.dpdns.org\", \"port\": \"2052\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link10" >> "$HOME/agsbx/jhsub.txt"
vma_link11="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-2082\", \"add\": \"yg10.ygkkk.dpdns.org\", \"port\": \"2082\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link11" >> "$HOME/agsbx/jhsub.txt"
vma_link12="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-2086\", \"add\": \"yg11.ygkkk.dpdns.org\", \"port\": \"2086\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link12" >> "$HOME/agsbx/jhsub.txt"
vma_link13="vmess://$(echo "{ \"v\": \"2\", \"ps\": \"${sxname}vmess-ws-argo-$hostname-2095\", \"add\": \"[2400:cb00:2049::0]\", \"port\": \"2095\", \"id\": \"$uuid\", \"aid\": \"0\", \"scy\": \"auto\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$argodomain\", \"path\": \"/$uuid-vm\", \"tls\": \"\"}" | base64 -w0)"
echo "$vma_link13" >> "$HOME/agsbx/jhsub.txt"
sbvmargopt(){
cat <<EOF
{
            "server": "$cdnip1",
            "server_port": 443,
            "tag": "${sxname}vmess-ws-tls-argo-$hostname-443",
            "tls": {
                "enabled": true,
                "server_name": "$argodomain",
                "insecure": false,
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                }
            },
            "packet_encoding": "packetaddr",
            "transport": {
                "headers": {
                    "Host": [
                        "$argodomain"
                    ]
                },
                "path": "$uuid-vm",
                "type": "ws"
            },
            "type": "vmess",
            "security": "auto",
            "uuid": "$uuid"
        },
{
            "server": "$cdnip2",
            "server_port": 80,
            "tag": "${sxname}vmess-ws-argo-$hostname-80",
            "tls": {
                "enabled": false,
                "server_name": "$argodomain",
                "insecure": false,
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                }
            },
            "packet_encoding": "packetaddr",
            "transport": {
                "headers": {
                    "Host": [
                        "$argodomain"
                    ]
                },
                "path": "$uuid-vm",
                "type": "ws"
            },
            "type": "vmess",
            "security": "auto",
            "uuid": "$uuid"
        },
EOF
}
sbvmargopt1(){
echo "\"${sxname}vmess-ws-tls-argo-$hostname-443\","
echo "\"${sxname}vmess-ws-argo-$hostname-80\","
}
clvmargopt(){
cat <<EOF
- name: ${sxname}vmess-ws-tls-argo-$hostname-443                         
  type: vmess
  server: "$cdnip1"                       
  port: 443                                     
  uuid: $uuid       
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  network: ws
  servername: $argodomain                    
  ws-opts:
    path: "$uuid-vm"                             
    headers:
      Host: $argodomain
- name: ${sxname}vmess-ws-argo-$hostname-80                         
  type: vmess
  server: "$cdnip2"                        
  port: 80                                     
  uuid: $uuid       
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  network: ws
  servername: $argodomain                    
  ws-opts:
    path: "$uuid-vm"                             
    headers:
      Host: $argodomain
EOF
}
clvmargopt1(){
echo "- ${sxname}vmess-ws-tls-argo-$hostname-443"
echo "- ${sxname}vmess-ws-argo-$hostname-80"
}
elif [ "$vlvm" = "Vless" ]; then
vwatls_link1="vless://$uuid@$cdnip1:443?encryption=$enkey&flow=xtls-rprx-vision&type=ws&host=$argodomain&path=$uuid-vw&security=tls&sni=$argodomain&fp=chrome&insecure=0&allowInsecure=0#${sxname}vless-ws-tls-argo-enc-vision-$hostname"
echo "$vwatls_link1" >> "$HOME/agsbx/jhsub.txt"
vwa_link2="vless://$uuid@$cdnip2:80?encryption=$enkey&flow=xtls-rprx-vision&type=ws&host=$argodomain&path=$uuid-vw&security=none#${sxname}vless-ws-argo-enc-vision-$hostname"
echo "$vwa_link2" >> "$HOME/agsbx/jhsub.txt"
fi
sbtk=$(cat "$HOME/agsbx/sbargotoken.log" 2>/dev/null)
if [ -n "$sbtk" ]; then
nametn="Argo固定隧道token：$sbtk"
fi
argoshow=$(
echo "Argo隧道端口正在使用$vlvm-ws主协议端口：$(cat $HOME/agsbx/argoport.log 2>/dev/null)
Argo域名：$argodomain
$nametn

1、💣443端口的$vlvm-ws-tls-argo节点(优选IP与443系端口随便换)
${vmatls_link1}${vwatls_link1}

2、💣80端口的$vlvm-ws-argo节点(优选IP与80系端口随便换)
${vma_link7}${vwa_link2}
"
)
fi

get_func() {
local f=$1
if type "$f" >/dev/null 2>&1; then
local out
out=$($f)
[ -n "$out" ] && printf "%s\n" "$out"
fi
}
sbxy="$(get_func sbvlpt; get_func sbsspt; get_func sbanpt; get_func sbarpt; get_func sbvmpt; get_func sbhypt; get_func sbtupt; get_func sbvmargopt)"
clxy="$(get_func clvlpt; get_func clsspt; get_func clanpt; get_func clvmpt; get_func clhypt; get_func cltupt; get_func clvmargopt; get_func clmieru)"
sbgz="$(get_func sbvlpt1; get_func sbsspt1; get_func sbanpt1; get_func sbarpt1; get_func sbvmpt1; get_func sbhypt1; get_func sbtupt1; get_func sbvmargopt1)"
clgz="$({ get_func clvlpt1; get_func clsspt1; get_func clanpt1; get_func clvmpt1; get_func clhypt1; get_func cltupt1; get_func clvmargopt1; get_func clmieru1; } | sed '2,$s/^/    /')"
sbgz=$(printf "%s\n" "$sbgz" | sed '$ s/,$//')
if [ "$legacy_output" = yes ]; then
cat > $HOME/agsbx/sbox.json <<EOF
{
    "log": {
        "disabled": false,
        "level": "info",
        "timestamp": true
    },
    "experimental": {
        "cache_file": {
            "enabled": true,
            "path": "./cache.db",
            "store_fakeip": true
        },
        "clash_api": {
            "external_controller": "127.0.0.1:9090",
            "external_ui": "ui",
            "default_mode": "Rule"
        }
    },
    "dns": {
        "servers": [
            {
                "tag": "aliDns",
                "type": "https",
                "server": "dns.alidns.com",
                "path": "/dns-query",
                "domain_resolver": "local"
            },
            {
                "tag": "local",
                "type": "udp",
                "server": "223.5.5.5"
            },
            {
                "tag": "proxyDns",
                "type": "https",
                "server": "dns.google",
                "path": "/dns-query",
	              "domain_resolver": "aliDns",
                "detour": "proxy"
            },
           {
        "type": "fakeip",
        "tag": "fakeip",
        "inet4_range": "198.18.0.0/15",
        "inet6_range": "fc00::/18"
      }
        ],
        "rules": [
            {
                "rule_set": "geosite-cn",
                "clash_mode": "Rule",
                "server": "aliDns"
            },
            {
                "clash_mode": "Direct",
                "server": "local"
            },
            {
                "clash_mode": "Global",
                "server": "proxyDns"
            },
            {
        "query_type": [
          "A",
          "AAAA"
        ],
        "server": "fakeip"
      }
        ],
        "final": "proxyDns",
        "strategy": "prefer_ipv4"
    },
    "inbounds": [
        {
            "type": "tun",
            "tag": "tun-in",
            "address": [
                "172.19.0.1/30",
                "fd00::1/126"
            ],
            "auto_route": true,
            "strict_route": true
        }
    ],
    "route": {
        "rules": [
            {
	 "inbound": "tun-in",
                "action": "sniff"
            },
            {
                "type": "logical",
                "mode": "or",
                "rules": [
                    {
                        "port": 53
                    },
                    {
                        "protocol": "dns"
                    }
                ],
                "action": "hijack-dns"
            },
         {
          "clash_mode": "Global",
          "outbound": "proxy"
         },
        {
        "rule_set": "geosite-cn",
        "clash_mode": "Rule",
        "outbound": "direct"
       },
     {
    "rule_set": "geoip-cn",
    "clash_mode": "Rule",
    "outbound": "direct"
      },
     {
    "ip_is_private": true,
    "clash_mode": "Rule",
    "outbound": "direct"
    },
     {
      "clash_mode": "Direct",
      "outbound": "direct"
     }		
        ],
        "rule_set": [
            {
                "tag": "geosite-cn",
                "type": "remote",
                "format": "binary",
                "url": "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geosite/geolocation-cn.srs",
                "download_detour": "direct"
            },
            {
                "tag": "geoip-cn",
                "type": "remote",
                "format": "binary",
                "url": "https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs",
                "download_detour": "direct"
            }
        ],
        "final": "proxy",
        "auto_detect_interface": true,
        "default_domain_resolver": {
        "server": "aliDns"
        }
    },
  "outbounds": [
   $sbxy
        {
            "tag": "proxy",
            "type": "selector",
            "default": "auto",
            "outbounds": [
        "auto",
        $sbgz
            ]
        },
        {
            "tag": "auto",
            "type": "urltest",
            "outbounds": [
            $sbgz
            ],
            "url": "http://www.gstatic.com/generate_204",
            "interval": "10m",
            "tolerance": 50
        },
        {
            "type": "direct",
            "tag": "direct"
        }
    ]
}
EOF

fi

cat > $HOME/agsbx/clmi.yaml <<EOF
port: 7890
allow-lan: true
mode: rule
log-level: info
unified-delay: true
dns:
  enable: true 
  listen: "0.0.0.0:1053"
  ipv6: true
  prefer-h3: false
  respect-rules: true
  use-system-hosts: false
  cache-algorithm: "arc"
  enhanced-mode: "fake-ip"
  fake-ip-range: "198.18.0.1/16"
  fake-ip-filter:
    - "+.lan"
    - "+.local"
    - "+.msftconnecttest.com"
    - "+.msftncsi.com"
    - "localhost.ptlogin2.qq.com"
    - "localhost.sec.qq.com"
    - "+.in-addr.arpa"
    - "+.ip6.arpa"
    - "time.*.com"
    - "time.*.gov"
    - "pool.ntp.org"
    - "localhost.work.weixin.qq.com"
  default-nameserver: ["223.5.5.5", "119.29.29.29"]
  nameserver:
    - "https://1.1.1.1/dns-query"
    - "https://8.8.8.8/dns-query"
  proxy-server-nameserver:
    - "https://223.5.5.5/dns-query"
    - "https://doh.pub/dns-query"

proxies:
$clxy

proxy-groups:
- name: 负载均衡
  type: load-balance
  url: https://www.gstatic.com/generate_204
  interval: 300
  strategy: round-robin
  proxies:
    $clgz
- name: 自动选择
  type: url-test
  url: https://www.gstatic.com/generate_204
  interval: 300
  tolerance: 50
  proxies:
    $clgz 
- name: 🌍选择代理节点
  type: select
  proxies:
    - 负载均衡                                         
    - 自动选择
    - DIRECT
    $clgz
rules:
  - GEOIP,LAN,DIRECT
  - GEOSITE,CN,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,🌍选择代理节点
EOF
echo "---------------------------------------------------------"
echo "$argoshow"
if [ -n "$mierushow" ]; then
echo "$mierushow"
fi
echo
if [ -s "$HOME/agsbx/subport.log" ] && [ -s "$HOME/agsbx/subtoken.log" ]; then
subsrv_enabled=no
[ -f "$HOME/agsbx/subscription.enabled" ] && subsrv_enabled=yes
if [ "$subsrv_enabled" = no ] && pgrep -f 'busybox.*httpd.*websbx' >/dev/null 2>&1; then
: > "$HOME/agsbx/subscription.enabled"
chmod 0600 "$HOME/agsbx/subscription.enabled" 2>/dev/null || true
subsrv_enabled=yes
fi
if [ "$subsrv_enabled" = yes ]; then
if ensure_subscription_available; then
showsubport=$(cat "$HOME/agsbx/subport.log")
showsubtoken=$(cat "$HOME/agsbx/subtoken.log")
subip=$(cat "$HOME/agsbx/server_ip.log" 2>/dev/null)
suburl="$subip:$showsubport/$showsubtoken"
echo "**********************************************************"
[ -s "$HOME/agsbx/clmi.yaml" ] && echo "Clash/Mihomo本地IP订阅地址：http://$suburl/clmi.yaml"
[ -s "$HOME/agsbx/sbox.json" ] && echo "Sing-box本地IP订阅地址：http://$suburl/sbox.json"
[ -s "$HOME/agsbx/jhsub.txt" ] && echo "聚合协议本地IP订阅地址：http://$suburl/jhsub.txt"
[ -s "$HOME/agsbx/mieru.txt" ] && echo "Mieru本地IP订阅地址：http://$suburl/mieru.txt"
echo "**********************************************************"
else
echo "错误：订阅 HTTP 服务或文件映射异常，请检查 $HOME/agsbx/sub-http.log" >&2
fi
fi
fi
echo
echo "---------------------------------------------------------"
echo "聚合节点信息，请进入 $HOME/agsbx/jhsub.txt 文件目录查看或者运行 cat $HOME/agsbx/jhsub.txt 查看"
[ -s "$HOME/agsbx/mieru.txt" ] && echo "Mieru 标准/简单链接保存在 $HOME/agsbx/mieru.txt"
echo "========================================================="
echo "相关快捷方式如下：(首次安装成功后需重连SSH，agsbx快捷方式才可生效；如未生效，请使用主脚本)"
showmode
}
cleandel(){
kill_exe "$HOME/agsbx/sing-box" TERM
kill_exe "$HOME/agsbx/xray" TERM
kill_exe "$HOME/agsbx/cloudflared" TERM
remove_mita_service
stop_subscription_server
rm -f "$HOME/agsbx/subscription.enabled" "$HOME/agsbx/sub-http.log"
clean_agsbx_bashrc
. "$HOME/.bashrc" 2>/dev/null || true
crontab -l > /tmp/crontab.tmp 2>/dev/null || : > /tmp/crontab.tmp
sed -i '/agsbx\/sing-box/d' /tmp/crontab.tmp
sed -i '/agsbx\/xray/d' /tmp/crontab.tmp
sed -i '/agsbx\/mita/d' /tmp/crontab.tmp
sed -i '/agsbx\/cloudflared/d' /tmp/crontab.tmp
sed -i '/websbx/d' /tmp/crontab.tmp
crontab /tmp/crontab.tmp >/dev/null 2>&1 || true
rm -f /tmp/crontab.tmp "$HOME/bin/agsbx"
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1; then
for svc in xr sb argo; do
systemctl stop "$svc" >/dev/null 2>&1 || true
systemctl disable "$svc" >/dev/null 2>&1 || true
done
rm -f /etc/systemd/system/xr.service /etc/systemd/system/sb.service /etc/systemd/system/argo.service
systemctl daemon-reload >/dev/null 2>&1 || true
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1; then
for svc in sing-box xray argo; do
rc-service "$svc" stop >/dev/null 2>&1 || true
rc-update del "$svc" default >/dev/null 2>&1 || true
done
rm -f /etc/init.d/sing-box /etc/init.d/xray /etc/init.d/argo /etc/local.d/alpineargosbx.start /etc/local.d/alpinesubsbx.start
iptables -t nat -F PREROUTING >/dev/null 2>&1 || true
netfilter-persistent save >/dev/null 2>&1 || true
rc-service iptables save >/dev/null 2>&1 || true
rc-service ip6tables save >/dev/null 2>&1 || true
fi
}
xrestart(){
[ -f "$HOME/agsbx/xr.json" ] || return 0
kill_exe "$HOME/agsbx/xray" TERM
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1 && [ -f /etc/systemd/system/xr.service ]; then
systemctl restart xr >/dev/null 2>&1
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1 && [ -f /etc/init.d/xray ]; then
rc-service xray restart >/dev/null 2>&1
else
nohup "$HOME/agsbx/xray" run -c "$HOME/agsbx/xr.json" >/dev/null 2>&1 &
fi
}
sbrestart(){
[ -f "$HOME/agsbx/sb.json" ] || return 0
kill_exe "$HOME/agsbx/sing-box" TERM
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1 && [ -f /etc/systemd/system/sb.service ]; then
systemctl restart sb >/dev/null 2>&1
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1 && [ -f /etc/init.d/sing-box ]; then
rc-service sing-box restart >/dev/null 2>&1
else
nohup "$HOME/agsbx/sing-box" run -c "$HOME/agsbx/sb.json" >/dev/null 2>&1 &
fi
}
argorestart(){
[ -f "$HOME/agsbx/argoport.log" ] || return 0
kill_exe "$HOME/agsbx/cloudflared" TERM
if [ -s "$HOME/agsbx/sbargotoken.log" ]; then
if [ "$(id -u)" -eq 0 ] && pidof systemd >/dev/null 2>&1 && [ -f /etc/systemd/system/argo.service ]; then
systemctl restart argo >/dev/null 2>&1
elif [ "$(id -u)" -eq 0 ] && command -v rc-service >/dev/null 2>&1 && [ -f /etc/init.d/argo ]; then
rc-service argo restart >/dev/null 2>&1
else
nohup "$HOME/agsbx/cloudflared" tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token "$(cat "$HOME/agsbx/sbargotoken.log")" >/dev/null 2>&1 &
fi
else
nohup "$HOME/agsbx/cloudflared" tunnel --url "http://localhost:$(cat "$HOME/agsbx/argoport.log")" --edge-ip-version auto --no-autoupdate --protocol http2 > "$HOME/agsbx/argo.log" 2>&1 &
fi
}
if [ "$1" = "del" ]; then
cleandel
rm -rf sbx_update "$HOME/agsbx" "$HOME/websbx"
echo "卸载完成"
echo "欢迎继续使用甬哥侃侃侃ygkkk的Argosbx一键无交互小钢炮脚本💣" && sleep 2
echo
showmode
exit
elif [ "$1" = "rep" ]; then
cleandel
rm -f "$HOME/agsbx"/sb.json "$HOME/agsbx"/xr.json "$HOME/agsbx"/sbargoym.log "$HOME/agsbx"/sbargotoken.log "$HOME/agsbx"/argo.log "$HOME/agsbx"/argoport.log "$HOME/agsbx"/cdnym "$HOME/agsbx"/name
cleanup_mieru_runtime
rm -f "$HOME/agsbx/sbox.json" "$HOME/agsbx/clmi.yaml" "$HOME/agsbx/jhsub.txt"
echo "Argosbx重置协议完成，开始更新相关协议变量……" && sleep 2
echo
elif [ "$1" = "list" ]; then
cip
exit
elif [ "$1" = "upx" ]; then
[ -f "$HOME/agsbx/xr.json" ] || { echo "错误：当前未启用 Xray" >&2; exit 1; }
kill_exe "$HOME/agsbx/xray" TERM
upxray && xrestart && echo "Xray内核更新完成" && sleep 2 && cip
exit
elif [ "$1" = "ups" ]; then
[ -f "$HOME/agsbx/sb.json" ] || { echo "错误：当前未启用 Sing-box" >&2; exit 1; }
kill_exe "$HOME/agsbx/sing-box" TERM
upsingbox && sbrestart && echo "Sing-box内核更新完成" && sleep 2 && cip
exit
elif [ "$1" = "upm" ]; then
if update_mieru_cores; then
sleep 2
cip
exit
fi
exit 1
elif [ "$1" = "res" ]; then
restarted=no
if [ -f "$HOME/agsbx/sb.json" ]; then sbrestart && restarted=yes; fi
if [ -f "$HOME/agsbx/xr.json" ]; then xrestart && restarted=yes; fi
if [ -f "$HOME/agsbx/mita.json" ]; then mitarestart && restarted=yes; fi
if [ -f "$HOME/agsbx/argoport.log" ]; then argorestart && restarted=yes; fi
[ "$restarted" = yes ] || { echo "错误：未找到可恢复的 Argosbx 配置" >&2; exit 1; }
sleep 5
echo "重启完成"
sleep 2
cip
exit
fi
if ! has_argosbx_install; then
kill_exe "$HOME/agsbx/sing-box" TERM
kill_exe "$HOME/agsbx/xray" TERM
kill_exe "$HOME/agsbx/cloudflared" TERM
stop_mita_runtime
if [ -z "$( (command -v curl >/dev/null 2>&1 && curl -s4m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -4 -qO- --tries=2 "$v46url" 2>/dev/null) )" ]; then
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a00:1098:2c::1" > /etc/resolv.conf
fi
if [ -n "$( (command -v curl >/dev/null 2>&1 && curl -s6m5 -k "$v46url" 2>/dev/null) || (command -v wget >/dev/null 2>&1 && timeout 3 wget -6 -qO- --tries=2 "$v46url" 2>/dev/null) )" ]; then
sendip="2606:4700:d0::a29f:c001"
xendip="[2606:4700:d0::a29f:c001]"
else
sendip="162.159.192.1"
xendip="162.159.192.1"
fi
echo "VPS系统：$op"
echo "CPU架构：$cpu"
echo "Argosbx脚本未安装，开始安装…………" && sleep 1
if [ -n "$oap" ]; then
setenforce 0 >/dev/null 2>&1
iptables -P INPUT ACCEPT >/dev/null 2>&1
iptables -P FORWARD ACCEPT >/dev/null 2>&1
iptables -P OUTPUT ACCEPT >/dev/null 2>&1
iptables -F >/dev/null 2>&1
netfilter-persistent save >/dev/null 2>&1
echo
echo "iptables执行开放所有端口"
fi
ins
if [ -n "$sub" ]; then
if [ -z "$subid" ]; then
subtoken="$(cat "$HOME/agsbx/uuid")"
else
subtoken="$subid"
fi
subscription_token_is_valid "$subtoken" || { echo "错误：subid 必须是 1-128 位 URL-safe ASCII" >&2; exit 1; }
subsrv_old_token=$(cat "$HOME/agsbx/subtoken.log" 2>/dev/null)
if subscription_token_is_valid "$subsrv_old_token" && [ "$subsrv_old_token" != "$subtoken" ]; then
rm -rf "$HOME/websbx/$subsrv_old_token"
fi
stop_subscription_server
subport=$(choose_subscription_port) || exit 1
umask 077
printf '%s\n' "$subtoken" > "$HOME/agsbx/subtoken.log"
printf '%s\n' "$subport" > "$HOME/agsbx/subport.log"
: > "$HOME/agsbx/subscription.enabled"
chmod 0600 "$HOME/agsbx/subtoken.log" "$HOME/agsbx/subport.log" "$HOME/agsbx/subscription.enabled"
echo "请稍后…………"
mkdir -p "$HOME/websbx/$subtoken"
start_subscription_server || { rm -f "$HOME/agsbx/subscription.enabled"; exit 1; }
if command -v apk >/dev/null 2>&1; then
cat > /etc/local.d/alpinesubsbx.start <<EOF
#!/bin/bash
sleep 10
busybox-extras httpd -f -p \$(cat $HOME/agsbx/subport.log 2>/dev/null) -h $HOME/websbx > $HOME/agsbx/sub-http.log 2>&1 &
EOF
chmod +x /etc/local.d/alpinesubsbx.start
rc-update add local default >/dev/null 2>&1
else
crontab -l 2>/dev/null > /tmp/crontab.tmp
sed -i '/websbx/d' /tmp/crontab.tmp
echo '@reboot sleep 10 && /bin/bash -c "busybox httpd -f -p $(cat $HOME/agsbx/subport.log 2>/dev/null) -h $HOME/websbx > $HOME/agsbx/sub-http.log 2>&1 &"' >> /tmp/crontab.tmp
crontab /tmp/crontab.tmp >/dev/null 2>&1
rm /tmp/crontab.tmp
fi
echo "本地IP订阅链接已更新完成"
fi
if [ -n "$hyjpt" ] && [ -n "$hyp" ]; then
echo
echo "设置Hysteria2协议的跳跃端口：$hyjpt"
iptables -t nat -F PREROUTING >/dev/null 2>&1
ip6tables -t nat -F PREROUTING >/dev/null 2>&1
hyport=$(cat "$HOME/agsbx/port_hy2")
for port in $hyjpt; do
iptables -t nat -A PREROUTING -p udp --dport "$port" -j DNAT --to-destination :$hyport
ip6tables -t nat -A PREROUTING -p udp --dport "$port" -j DNAT --to-destination :$hyport
done
netfilter-persistent save >/dev/null 2>&1
if command -v rc-service >/dev/null 2>&1 && command -v rc-update >/dev/null 2>&1; then
rc-update show default 2>/dev/null | grep -q 'iptables' || rc-update add iptables >/dev/null 2>&1
rc-update show default 2>/dev/null | grep -q 'ip6tables' || rc-update add ip6tables >/dev/null 2>&1
rc-service iptables save >/dev/null 2>&1
rc-service ip6tables save >/dev/null 2>&1
fi
fi
cip
if [ -f "$HOME/agsbx/subscription.enabled" ] && ! subscription_probe; then
echo "错误：订阅地址启动验收失败，请检查 $HOME/agsbx/sub-http.log" >&2
exit 1
fi
echo
else
echo "Argosbx脚本已安装"
echo
argosbxstatus
echo
echo "相关快捷方式如下："
showmode
exit
fi
