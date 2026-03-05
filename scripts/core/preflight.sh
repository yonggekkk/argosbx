#!/usr/bin/env bash
set -euo pipefail
# Preflight checks: ports, IPv6, NAT/LXC, firewall, time sync
ok=true
err(){ echo "[X] $1"; ok=false; }
info(){ echo "[+] $1"; }

# Check commands
for c in curl jq grep awk sed systemctl; do command -v $c >/dev/null 2>&1 || err "missing cmd: $c"; done

# Time sync (SS2022 sensitive)
if command -v timedatectl >/dev/null 2>&1; then
  ntp=$(timedatectl 2>/dev/null | grep -i 'System clock synchronized' | awk '{print $4}')
  [ "$ntp" = "yes" ] || info "NTP not synced; SS2022 may fail if clocks drift"
fi

# IPv6 presence
ip -6 addr >/dev/null 2>&1 && info "IPv6 detected" || info "No IPv6 (ok)"

# Firewall quick check
if command -v ufw >/dev/null 2>&1; then
  ufw status | sed -n '1,20p'
fi

# Ports to check (common defaults)
ports=(443 8443 8448 8449 8450)
for p in "${ports[@]}"; do
  ss -lntup 2>/dev/null | grep -q ":$p\b" && info "port $p in use" || true
done

# NAT/LXC heuristic
if systemd-detect-virt -c >/dev/null 2>&1; then
  virt=$(systemd-detect-virt -c)
  info "container: $virt (Hy2 port hopping may need app-level mode)"
fi

$ok || exit 1
