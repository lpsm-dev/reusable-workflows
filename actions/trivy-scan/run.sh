#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'trivy-scan: %s\n' "$1" >&2
  exit 1
}

resolve_workspace_path() {
  local requested="$1" resolved
  [[ -n "$requested" && "$requested" != /* ]] || fail 'file paths must be relative to GITHUB_WORKSPACE'
  resolved="$(realpath -- "$workspace/$requested")" || fail "path does not exist: $requested"
  case "$resolved" in
    "$workspace"|"$workspace"/*) printf '%s\n' "$resolved" ;;
    *) fail 'file path resolves outside GITHUB_WORKSPACE' ;;
  esac
}

[[ "${RUNNER_OS:-}" == Linux && "${RUNNER_ARCH:-}" == X64 ]] || fail 'only Linux x64 runners are supported'
[[ -n "${GITHUB_WORKSPACE:-}" && -d "$GITHUB_WORKSPACE" ]] || fail 'GITHUB_WORKSPACE is unavailable'
[[ -n "${RUNNER_TEMP:-}" && -d "$RUNNER_TEMP" ]] || fail 'RUNNER_TEMP is unavailable'
command -v jq > /dev/null || fail 'jq is required on the runner'
tool="${1:-}"
[[ -x "$tool" ]] || fail 'Trivy executable is unavailable'
workspace="$(realpath -- "$GITHUB_WORKSPACE")"

case "${SCAN_TYPE:-}" in
  fs)
    [[ -n "${TARGET:-}" ]] || fail 'target is required'
    resolved_target="$(resolve_workspace_path "$TARGET")"
    [[ -f "$resolved_target" || -d "$resolved_target" ]] || fail 'filesystem target must be a file or directory'
    ;;
  image)
    [[ "${TARGET:-}" =~ ^[A-Za-z0-9][A-Za-z0-9._:/-]*@sha256:[0-9a-fA-F]{64}$ ]] || fail 'image target must be pinned by sha256 digest'
    resolved_target="$TARGET"
    ;;
  *) fail 'scan-type must be fs or image' ;;
esac

arguments=("$SCAN_TYPE" --scanners vuln --severity 'HIGH,CRITICAL' --exit-code 1 --format json --list-all-pkgs)
if [[ -n "${IGNORE_FILE:-}" ]]; then
  resolved_ignore="$(resolve_workspace_path "$IGNORE_FILE")"
  [[ -f "$resolved_ignore" ]] || fail 'ignorefile must be a file'
  arguments+=(--ignorefile "$resolved_ignore")
fi

report="$(mktemp "$RUNNER_TEMP/trivy-report.XXXXXX")"
trap 'rm -f "$report"' EXIT
arguments+=(--output "$report" "$resolved_target")

status=0
"$tool" "${arguments[@]}" || status=$?
if [[ ! -s "$report" ]]; then
  (( status != 0 )) && exit "$status"
  fail 'Trivy did not produce a report'
fi
if ! jq -e '[.Results[]?.Packages[]?] | length > 0' "$report" > /dev/null; then
  (( status != 0 )) && exit "$status"
  fail 'target contains no packages applicable to the vulnerability scan'
fi

jq -r '.Results[]? | .Target as $target | .Vulnerabilities[]? | "\($target): \(.VulnerabilityID) [\(.Severity)]"' "$report"
(( status == 0 )) || exit "$status"
printf 'Trivy vulnerability scan passed\n'
