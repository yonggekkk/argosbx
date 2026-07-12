#!/bin/sh

is_exact_exe_running(){
  target=$(readlink -f "$1" 2>/dev/null || printf '%s' "$1")
  for exe in /proc/[0-9]*/exe; do
    [ -L "$exe" ] || continue
    [ "$(readlink -f "$exe" 2>/dev/null)" = "$target" ] && return 0
  done
  return 1
}

kill_exact_exe(){
  target=$(readlink -f "$1" 2>/dev/null || printf '%s' "$1")
  for exe in /proc/[0-9]*/exe; do
    [ -L "$exe" ] || continue
    if [ "$(readlink -f "$exe" 2>/dev/null)" = "$target" ]; then
      kill "$(basename "$(dirname "$exe")")" 2>/dev/null || true
    fi
  done
}

mi_port_valid(){
  printf '%s' "$1" | grep -Eq '^[1-9][0-9]*(-[1-9][0-9]*)?$' || return 1
  case "$1" in *-*) a=${1%-*}; b=${1#*-} ;; *) a=$1; b=$1 ;; esac
  [ "$a" -ge 1025 ] 2>/dev/null && [ "$b" -le 65535 ] 2>/dev/null && [ "$a" -le "$b" ] 2>/dev/null
}

mi_validate_port(){
  spec=$1
  label=$2
  case "$spec" in *,*|*' '*|*'\t'*) echo "错误：$label 仅支持单端口或递增范围：$spec" >&2; return 1 ;; esac
  mi_port_valid "$spec" || { echo "错误：$label 必须是 1025-65535 的单端口或递增范围：$spec" >&2; return 1; }
  case "$spec" in *-*) [ "${spec%-*}" -lt "${spec#*-}" ] || { echo "错误：$label 范围必须严格递增：$spec" >&2; return 1; } ;; esac
}

mi_overlap(){
  case "$1" in *-*) a1=${1%-*}; a2=${1#*-} ;; *) a1=$1; a2=$1 ;; esac
  case "$2" in *-*) b1=${2%-*}; b2=${2#*-} ;; *) b1=$2; b2=$2 ;; esac
  [ "$a1" -le "$b2" ] && [ "$b1" -le "$a2" ]
}

mi_contains(){
  case "$1" in *-*) a=${1%-*}; b=${1#*-} ;; *) a=$1; b=$1 ;; esac
  [ "$2" -ge "$a" ] 2>/dev/null && [ "$2" -le "$b" ] 2>/dev/null
}

mi_saved_port_conflict(){
  spec=$1
  for file in "$HOME/agsbx"/*pt "$HOME/agsbx"/port_*; do
    [ -f "$file" ] || continue
    case "$(basename "$file")" in mitpt|miupt|port_mi_tcp|port_mi_udp) continue ;; esac
    other=$(cat "$file" 2>/dev/null)
    mi_port_valid "$other" || continue
    if mi_overlap "$spec" "$other"; then
      echo "错误：Mieru 端口 $spec 与现有 Argosbx 端口 $(basename "$file")=$other 冲突" >&2
      return 0
    fi
  done
  return 1
}

mi_listener_conflict(){
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
  old=''
  case "$protocol" in TCP) old=$(cat "$HOME/agsbx/port_mi_tcp" 2>/dev/null) ;; UDP) old=$(cat "$HOME/agsbx/port_mi_udp" 2>/dev/null) ;; esac
  while IFS= read -r line; do
    set -- $line
    addr=${4:-}
    port=${addr##*:}
    port=${port%]}
    case "$port" in ''|*[!0-9]*) continue ;; esac
    mi_contains "$spec" "$port" || continue
    if is_exact_exe_running "$HOME/agsbx/mita" && mi_port_valid "$old" && mi_contains "$old" "$port"; then
      continue
    fi
    echo "错误：Mieru $protocol 端口 $port 已被监听：$line" >&2
    return 0
  done <<EOF
$lines
EOF
  return 1
}

mi_conflict(){
  mi_saved_port_conflict "$2" && return 0
  mi_listener_conflict "$1" "$2" && return 0
  return 1
}

mi_random_port(){
  protocol=$1
  avoid=${2:-}
  i=0
  while [ "$i" -lt 1000 ]; do
    port=$(shuf -i 1025-65535 -n 1)
    [ -n "$avoid" ] && [ "$port" = "$avoid" ] && { i=$((i+1)); continue; }
    if ! mi_conflict "$protocol" "$port"; then printf '%s\n' "$port"; return 0; fi
    i=$((i+1))
  done
  return 1
}

mi_password(){
  openssl rand -base64 24 | tr '+/' '-_' | tr -d '=\r\n'
}

mi_uuid(){
  if [ -r /proc/sys/kernel/random/uuid ]; then cat /proc/sys/kernel/random/uuid; else uuidgen; fi
}

mi_prepare(){
  old_user=$(cat "$HOME/agsbx/miuser" 2>/dev/null)
  old_pass=$(cat "$HOME/agsbx/mipass" 2>/dev/null)
  [ -n "$miuser" ] && mieru_user=$miuser || mieru_user=${old_user:-argosbx}
  [ -n "$mipass" ] && mieru_pass=$mipass || mieru_pass=${old_pass:-$(mi_password)}
  printf '%s' "$mieru_user" | LC_ALL=C grep -Eq '^[A-Za-z0-9._~-]{1,64}$' || { echo "错误：miuser 必须是 1-64 位 URL-safe ASCII" >&2; return 1; }
  printf '%s' "$mieru_pass" | LC_ALL=C grep -Eq '^[A-Za-z0-9._~-]{12,128}$' || { echo "错误：mipass 必须是 12-128 位 URL-safe ASCII" >&2; return 1; }

  tcp_random=no
  udp_random=no
  if [ "$mit" = yes ]; then
    if [ -n "$mitpt" ]; then mi_tcp=$mitpt
    elif [ -s "$HOME/agsbx/port_mi_tcp" ]; then mi_tcp=$(cat "$HOME/agsbx/port_mi_tcp")
    else tcp_random=yes; mi_tcp=$(mi_random_port TCP) || return 1
    fi
    mi_validate_port "$mi_tcp" mitpt || return 1
    mi_conflict TCP "$mi_tcp" && return 1
  fi
  if [ "$miu" = yes ]; then
    if [ -n "$miupt" ]; then mi_udp=$miupt
    elif [ -s "$HOME/agsbx/port_mi_udp" ]; then mi_udp=$(cat "$HOME/agsbx/port_mi_udp")
    else
      udp_random=yes
      avoid=''; [ "$tcp_random" = yes ] && avoid=$mi_tcp
      mi_udp=$(mi_random_port UDP "$avoid") || return 1
    fi
    mi_validate_port "$mi_udp" miupt || return 1
    mi_conflict UDP "$mi_udp" && return 1
  fi
  [ "$tcp_random" = yes ] && [ "$udp_random" = yes ] && [ "$mi_tcp" = "$mi_udp" ] && return 1

  umask 077
  printf '%s\n' "$mieru_user" > "$HOME/agsbx/miuser"
  printf '%s\n' "$mieru_pass" > "$HOME/agsbx/mipass"
  if [ "$mit" = yes ]; then printf '%s\n' "$mi_tcp" > "$HOME/agsbx/port_mi_tcp"; : > "$HOME/agsbx/mieru_tcp.enabled"; else rm -f "$HOME/agsbx/mieru_tcp.enabled"; fi
  if [ "$miu" = yes ]; then printf '%s\n' "$mi_udp" > "$HOME/agsbx/port_mi_udp"; : > "$HOME/agsbx/mieru_udp.enabled"; else rm -f "$HOME/agsbx/mieru_udp.enabled"; fi
  chmod 0600 "$HOME/agsbx/miuser" "$HOME/agsbx/mipass" "$HOME/agsbx"/port_mi_* "$HOME/agsbx"/mieru_*.enabled 2>/dev/null || true
  if [ -n "${uuid:-}" ]; then printf '%s\n' "$uuid" > "$HOME/agsbx/uuid"; chmod 0600 "$HOME/agsbx/uuid"; elif [ ! -s "$HOME/agsbx/uuid" ]; then mi_uuid > "$HOME/agsbx/uuid"; chmod 0600 "$HOME/agsbx/uuid"; fi
}

mi_download(){
  url=$1
  out=$2
  if command -v curl >/dev/null 2>&1; then curl -fL --retry 3 --connect-timeout 10 -o "$out" "$url"; else wget -O "$out" --tries=3 --timeout=20 "$url"; fi
}

mi_install_cores(){
  [ -x "$HOME/agsbx/mita" ] && [ -x "$HOME/agsbx/mieru" ] && return 0
  tmp="$HOME/agsbx/.mieru-download.$$"
  rm -rf "$tmp"; mkdir -p "$tmp"
  base="https://github.com/$ARGOSBX_ASSET_REPO/releases/download/$MIERU_RELEASE_TAG"
  mi_download "$base/SHA256SUMS" "$tmp/SHA256SUMS" || { rm -rf "$tmp"; return 1; }
  for core in mita mieru; do
    asset="$core-linux-$cpu"
    mi_download "$base/$asset" "$tmp/$asset" || { rm -rf "$tmp"; return 1; }
    expected=$(awk -v name="$asset" '{n=$2; sub(/^\*/, "", n); if(n==name){print $1; exit}}' "$tmp/SHA256SUMS")
    actual=$(sha256sum "$tmp/$asset" | awk '{print $1}')
    [ -n "$expected" ] && [ "$expected" = "$actual" ] || { echo "错误：$asset SHA-256 校验失败" >&2; rm -rf "$tmp"; return 1; }
    chmod 0755 "$tmp/$asset"
  done
  for core in mita mieru; do
    asset="$core-linux-$cpu"
    new="$HOME/agsbx/.$core.new.$$"
    mv "$tmp/$asset" "$new" && mv -f "$new" "$HOME/agsbx/$core" || { rm -rf "$tmp" "$new"; return 1; }
  done
  rm -rf "$tmp"
}

mi_write_server(){
  umask 077
  {
    echo '{'
    echo '  "portBindings": ['
    first=yes
    if [ "$mit" = yes ]; then
      case "$mi_tcp" in *-*) entry="{\"portRange\": \"$mi_tcp\", \"protocol\": \"TCP\"}" ;; *) entry="{\"port\": $mi_tcp, \"protocol\": \"TCP\"}" ;; esac
      printf '    %s' "$entry"; first=no
    fi
    if [ "$miu" = yes ]; then
      [ "$first" = yes ] || echo ','
      case "$mi_udp" in *-*) entry="{\"portRange\": \"$mi_udp\", \"protocol\": \"UDP\"}" ;; *) entry="{\"port\": $mi_udp, \"protocol\": \"UDP\"}" ;; esac
      printf '    %s' "$entry"
    fi
    cat <<EOF

  ],
  "users": [{"name": "$mieru_user", "password": "$mieru_pass"}],
  "loggingLevel": "INFO",
  "mtu": 1400
}
EOF
  } > "$HOME/agsbx/mita.json"
  chmod 0600 "$HOME/agsbx/mita.json"
}

mi_status(){
  [ -x "$HOME/agsbx/mita" ] || return 1
  env MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json" MITA_UDS_PATH="$HOME/agsbx/mita.sock" MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true "$HOME/agsbx/mita" status 2>&1 | grep -q 'status is "RUNNING"'
}

mi_start(){
  kill_exact_exe "$HOME/agsbx/mita"
  rm -f "$HOME/agsbx/mita.sock"
  nohup env MITA_CONFIG_JSON_FILE="$HOME/agsbx/mita.json" MITA_UDS_PATH="$HOME/agsbx/mita.sock" MITA_INSECURE_UDS=1 MITA_LOG_NO_TIMESTAMP=true "$HOME/agsbx/mita" run > "$HOME/agsbx/mita.log" 2>&1 &
  i=0
  while [ "$i" -lt 10 ]; do mi_status && return 0; sleep 1; i=$((i+1)); done
  return 1
}

container_install_mieru(){
  mieru_selected || return 0
  if [ -n "${VCAP_APPLICATION:-}${VCAP_SERVICES:-}${CF_INSTANCE_IP:-}${SAP_JWT_TRUST_ACL:-}" ]; then
    MIERU_UNSUPPORTED=yes
    umask 077; if [ -n "${uuid:-}" ]; then printf '%s\n' "$uuid" > "$HOME/agsbx/uuid"; chmod 0600 "$HOME/agsbx/uuid"; elif [ ! -s "$HOME/agsbx/uuid" ]; then mi_uuid > "$HOME/agsbx/uuid"; chmod 0600 "$HOME/agsbx/uuid"; fi
    rm -f "$HOME/agsbx/mita.json" "$HOME/agsbx/mita.sock" "$HOME/agsbx/mieru.txt" "$HOME/agsbx"/mieru_*.enabled
    echo "不支持：当前 Cloud Foundry/SAP 环境仅提供 HTTP 路由，Mieru 需要原生 TCP/UDP 端口，Mita 不会启动"
    return 0
  fi
  mi_prepare || return 1
  mi_install_cores || return 1
  mi_write_server
  [ "$wap" = yes ] && echo "提示：WARP 仅作用于 Xray/sing-box，Mieru 保持公网直连"
  echo "提示：Docker 必须显式映射完整 Mieru TCP/UDP 端口或范围"
  mi_start || { echo "错误：Mita 启动失败，请检查 $HOME/agsbx/mita.log" >&2; return 1; }
  echo "Mita $MIERU_VERSION 已运行"
}

mi_write_client(){
  local out tcp udp address ip domain user pass first entry
  out=$1; tcp=$2; udp=$3
  address=${server_ip#[}; address=${address%]}
  case "$address" in *:*|[0-9]*.[0-9]*.[0-9]*.[0-9]*) ip=$address; domain='' ;; *) ip=''; domain=$address ;; esac
  user=$(cat "$HOME/agsbx/miuser"); pass=$(cat "$HOME/agsbx/mipass")
  umask 077
  {
    cat <<EOF
{"profiles":[{"profileName":"argosbx","user":{"name":"$user","password":"$pass"},"servers":[{"ipAddress":"$ip","domainName":"$domain","portBindings":[
EOF
    first=yes
    if [ -n "$tcp" ]; then case "$tcp" in *-*) entry="{\"portRange\":\"$tcp\",\"protocol\":\"TCP\"}" ;; *) entry="{\"port\":$tcp,\"protocol\":\"TCP\"}" ;; esac; printf '%s' "$entry"; first=no; fi
    if [ -n "$udp" ]; then [ "$first" = yes ] || echo ','; case "$udp" in *-*) entry="{\"portRange\":\"$udp\",\"protocol\":\"UDP\"}" ;; *) entry="{\"port\":$udp,\"protocol\":\"UDP\"}" ;; esac; printf '%s' "$entry"; fi
    cat <<EOF
]}],"mtu":1400}],"activeProfile":"argosbx","rpcPort":0,"socks5Port":1080,"loggingLevel":"INFO","socks5ListenLAN":false}
EOF
  } > "$out"
}

mi_export(){
  local cfg mode out url
  cfg=$1; mode=$2
  if [ "$mode" = simple ]; then out=$(MIERU_CONFIG_JSON_FILE="$cfg" "$HOME/agsbx/mieru" export config simple 2>&1); else out=$(MIERU_CONFIG_JSON_FILE="$cfg" "$HOME/agsbx/mieru" export config 2>&1); fi
  url=$(printf '%s\n' "$out" | grep -Eo 'mierus?://[^[:space:]]+' | tail -n 1)
  [ -n "$url" ] || return 1
  printf '%s\n' "$url"
}

container_generate_mieru_links(){
  local tcp udp combo simple standard tcp_url udp_url tc uc tmp
  mieru_show=''
  [ -f "$HOME/agsbx/mita.json" ] || return 0
  tcp=''; udp=''
  [ -f "$HOME/agsbx/mieru_tcp.enabled" ] && tcp=$(cat "$HOME/agsbx/port_mi_tcp")
  [ -f "$HOME/agsbx/mieru_udp.enabled" ] && udp=$(cat "$HOME/agsbx/port_mi_udp")
  combo="$HOME/agsbx/.mieru-client.combo.$$"
  mi_write_client "$combo" "$tcp" "$udp"
  simple=$(mi_export "$combo" simple) || return 1
  standard=$(mi_export "$combo" standard) || return 1
  "$HOME/agsbx/mieru" explain config "$simple" >/dev/null 2>&1 && "$HOME/agsbx/mieru" explain config "$standard" >/dev/null 2>&1 || return 1
  tcp_url=''; udp_url=''
  if [ -n "$tcp" ] && [ -n "$udp" ]; then
    tc="$HOME/agsbx/.mieru-client.tcp.$$"; uc="$HOME/agsbx/.mieru-client.udp.$$"
    mi_write_client "$tc" "$tcp" ''; mi_write_client "$uc" '' "$udp"
    tcp_url=$(mi_export "$tc" simple) || return 1
    udp_url=$(mi_export "$uc" simple) || return 1
    "$HOME/agsbx/mieru" explain config "$tcp_url" >/dev/null 2>&1 && "$HOME/agsbx/mieru" explain config "$udp_url" >/dev/null 2>&1 || return 1
  fi
  tmp="$HOME/agsbx/.mieru-links.$$"
  { printf '%s\n' "$simple"; [ -n "$tcp_url" ] && printf '%s\n' "$tcp_url"; [ -n "$udp_url" ] && printf '%s\n' "$udp_url"; printf '%s\n' "$standard"; } > "$tmp"
  chmod 0600 "$tmp"; mv -f "$tmp" "$HOME/agsbx/mieru.txt"
  printf '%s\n' "$simple" >> "$HOME/agsbx/jh.txt"
  rm -f "$combo" "$tc" "$uc"
  mieru_show="Mieru $MIERU_VERSION 公网直连节点：
组合简单链接：$simple"
  [ -n "$tcp_url" ] && mieru_show="$mieru_show
TCP 独立简单链接：$tcp_url"
  [ -n "$udp_url" ] && mieru_show="$mieru_show
UDP 独立简单链接：$udp_url"
  mieru_show="$mieru_show
标准配置链接：$standard"
}
container_cores_running(){
  found=no
  if [ -f "$HOME/agsbx/xr.json" ]; then found=yes; is_exact_exe_running "$HOME/agsbx/xray" || return 1; fi
  if [ -f "$HOME/agsbx/sb.json" ]; then found=yes; is_exact_exe_running "$HOME/agsbx/sing-box" || return 1; fi
  if [ -f "$HOME/agsbx/mita.json" ]; then found=yes; mi_status || return 1; fi
  if [ "${MIERU_UNSUPPORTED:-}" = yes ]; then found=yes; fi
  [ "$found" = yes ]
}
