#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$ROOT/versions.env"

check_file() {
  file=$1
  value=$(sed -n 's/^MIERU_VERSION=//p' "$file" | head -n 1)
  tag=$(sed -n 's/^MIERU_RELEASE_TAG=//p' "$file" | head -n 1)
  [ "$value" = "$MIERU_VERSION" ] || {
    echo "MIERU_VERSION mismatch in $file: ${value:-missing}" >&2
    exit 1
  }
  [ "$tag" = "$MIERU_RELEASE_TAG" ] || {
    echo "MIERU_RELEASE_TAG mismatch in $file: ${tag:-missing}" >&2
    exit 1
  }
}

check_file "$ROOT/argosbx.sh"
check_file "$ROOT/container/nodejs/start.sh"
echo "Mieru version constants are consistent: $MIERU_VERSION ($MIERU_RELEASE_TAG)"