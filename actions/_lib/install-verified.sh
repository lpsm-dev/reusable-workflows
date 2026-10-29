#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "Usage: install-verified.sh URL SHA256 FORMAT MEMBER DEST" >&2
  exit 2
fi

url=$1
expected=$2
format=$3
member=$4
destination=$5

if [[ ! $url =~ ^https://[^[:space:]]+$ ]]; then
  echo "Download URL must use HTTPS" >&2
  exit 2
fi
if [[ ! $expected =~ ^[[:xdigit:]]{64}$ ]]; then
  echo "Expected SHA-256 must contain 64 hexadecimal digits" >&2
  exit 2
fi
case "$format" in
  raw)
    if [[ -n $member ]]; then
      echo "A raw asset must not have an archive member" >&2
      exit 2
    fi
    ;;
  tar.gz|tar.xz)
    if [[ -z $member || $member = /* || $member = *..* ]]; then
      echo "Archive member must be a safe relative path" >&2
      exit 2
    fi
    ;;
  *)
    echo "Unsupported asset format: $format" >&2
    exit 2
    ;;
esac

if [[ -z ${RUNNER_TEMP:-} ]] || ! python3 - "$RUNNER_TEMP" "$destination" <<'PY'
import os
import sys

root, destination = map(os.path.realpath, sys.argv[1:])
sys.exit(0 if os.path.commonpath((root, destination)) == root and destination != root else 1)
PY
then
  echo "Destination must be inside RUNNER_TEMP" >&2
  exit 2
fi

work=$(mktemp -d "${RUNNER_TEMP%/}/verified-download.XXXXXX")
trap 'rm -rf "$work"' EXIT
asset="$work/asset"
curl -fsSL --proto '=https' --tlsv1.2 --retry 3 --max-time 120 -o "$asset" "$url"
read -r actual _ < <(sha256sum "$asset")
if [[ $actual != "$expected" ]]; then
  echo "SHA-256 verification failed for downloaded asset" >&2
  exit 1
fi

binary="$work/binary"
case "$format" in
  raw) cp "$asset" "$binary" ;;
  tar.gz) tar -xzOf "$asset" "$member" > "$binary" ;;
  tar.xz) tar -xJOf "$asset" "$member" > "$binary" ;;
esac
if [[ ! -s $binary ]]; then
  echo "Downloaded binary is empty" >&2
  exit 1
fi
mkdir -p "$(dirname "$destination")"
install -m 0755 "$binary" "$destination"
