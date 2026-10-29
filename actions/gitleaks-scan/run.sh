#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'gitleaks-scan: %s\n' "$1" >&2
  exit 1
}

[[ "${RUNNER_OS:-}" == Linux && "${RUNNER_ARCH:-}" == X64 ]] || fail 'only Linux x64 runners are supported'
[[ -n "${GITHUB_WORKSPACE:-}" && -d "$GITHUB_WORKSPACE" ]] || fail 'GITHUB_WORKSPACE is unavailable'
[[ -n "${RUNNER_TEMP:-}" && -d "$RUNNER_TEMP" ]] || fail 'RUNNER_TEMP is unavailable'
tool="${1:-}"
[[ -x "$tool" ]] || fail 'Gitleaks executable is unavailable'
workspace="$(realpath -- "$GITHUB_WORKSPACE")"

config="${CONFIG:-}"
if [[ -z "$config" && -f "$workspace/.github/config/.gitleaks.toml" ]]; then
  config='.github/config/.gitleaks.toml'
fi
arguments=(detect --no-git --redact --no-banner)
if [[ -n "$config" ]]; then
  [[ "$config" != /* ]] || fail 'config must be relative to GITHUB_WORKSPACE'
  resolved="$(realpath -- "$workspace/$config")" || fail "config does not exist: $config"
  case "$resolved" in
    "$workspace"/*) ;;
    *) fail 'config resolves outside GITHUB_WORKSPACE' ;;
  esac
  [[ -f "$resolved" ]] || fail "config must be a file: $config"
  arguments+=(--config "$resolved")
fi

scan_root="$(mktemp -d "$RUNNER_TEMP/gitleaks-scan.XXXXXX")"
trap 'rm -rf "$scan_root"' EXIT
git -C "$workspace" archive --format=tar HEAD | tar -x -C "$scan_root"
[[ -n "$(find "$scan_root" -type f -print -quit)" ]] || fail 'no files in committed HEAD snapshot'
arguments+=(--source "$scan_root")
"$tool" "${arguments[@]}"
