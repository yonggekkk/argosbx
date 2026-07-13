#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(dirname "$script_dir")
main_script="$repo_dir/argosbx.sh"

subscription_functions=$(awk '
  /^subscription_token_is_valid\(\)/ { capture=1 }
  /^choose_random_mieru_port\(\)/ { capture=0 }
  capture { print }
' "$main_script")
eval "$subscription_functions"

test_home=$(mktemp -d)
server_pid=''
cleanup(){
  [ -z "$server_pid" ] || kill "$server_pid" >/dev/null 2>&1 || true
  rm -rf "$test_home"
}
trap cleanup EXIT INT TERM

HOME=$test_home
mkdir -p "$HOME/agsbx" "$HOME/websbx"

subscription_token_is_valid 'valid.Token_~-123'
! subscription_token_is_valid 'invalid/token'
! subscription_token_is_valid ''
subscription_port_is_valid 1025
subscription_port_is_valid 65535
! subscription_port_is_valid 1024
! subscription_port_is_valid 65536
! subscription_port_is_valid '12-13'

token='test-token'
printf '%s\n' "$token" > "$HOME/agsbx/subtoken.log"

python_bin=${PYTHON_BIN:-}
if [ -z "$python_bin" ]; then
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys' >/dev/null 2>&1; then
      python_bin=$(command -v "$candidate")
      break
    fi
  done
fi
[ -n "$python_bin" ] || {
  echo 'SKIP: python is required for the HTTP subscription regression test'
  exit 0
}

# The bundled Windows test shell may omit ln; Linux CI exercises the real symlink path.
if ! command -v ln >/dev/null 2>&1; then
  ln(){
    shift
    "$python_bin" -c 'import shutil,sys; shutil.copyfile(sys.argv[1], sys.argv[2])' "$1" "$2"
  }
fi

port=$("$python_bin" -c "import socket; s=socket.socket(); s.bind(('127.0.0.1', 0)); print(s.getsockname()[1]); s.close()")
printf '%s\n' "$port" > "$HOME/agsbx/subport.log"
mkdir -p "$HOME/websbx/$token"
"$python_bin" -m http.server "$port" --bind 127.0.0.1 --directory "$HOME/websbx" > "$HOME/http.log" 2>&1 &
server_pid=$!
"$python_bin" -c 'import time; time.sleep(1)'

# Reproduce the original first-install order: HTTP starts before cip creates jhsub.txt.
printf '%s\n' 'vmess://regression-test' > "$HOME/agsbx/jhsub.txt"
if subscription_probe; then
  echo 'FAIL: the unpublished subscription unexpectedly returned HTTP 200' >&2
  exit 1
fi

sync_subscription_files
subscription_probe
[ "$(cat "$HOME/websbx/$token/jhsub.txt")" = 'vmess://regression-test' ]

echo 'Subscription mapping regression test passed'
