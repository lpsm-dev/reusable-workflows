#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ACTION="$ROOT/actions/trivy-scan/run.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/workspace" "$TEST_ROOT/bin"
printf '{"name":"fixture","lockfileVersion":3,"packages":{}}\n' > "$TEST_ROOT/workspace/package-lock.json"
printf '# reviewed exception\n' > "$TEST_ROOT/workspace/.trivyignore"

cat > "$TEST_ROOT/bin/fake-trivy" <<'FAKE_TRIVY'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" > "$FAKE_TRIVY_LOG"
report=''
previous=''
for argument in "$@"; do
  if [[ "$previous" == '--output' ]]; then report="$argument"; fi
  previous="$argument"
done
case "${FAKE_TRIVY_MODE:-clean}" in
  clean) printf '{"Results":[{"Target":"fixture","Packages":[{"Name":"ok"}]}]}\n' > "$report" ;;
  high) printf '{"Results":[{"Target":"fixture","Packages":[{"Name":"bad"}],"Vulnerabilities":[{"VulnerabilityID":"CVE-TEST-1","Severity":"HIGH"}]}]}\n' > "$report"; exit 1 ;;
  no-packages) printf '{"Results":[]}\n' > "$report" ;;
  db-error) printf 'database download failed\n' >&2; exit 2 ;;
esac
FAKE_TRIVY
chmod +x "$TEST_ROOT/bin/fake-trivy"
ln -s "$(command -v jq)" "$TEST_ROOT/bin/jq"

run_action() {
  local scan_type="$1" target="$2" ignorefile="$3" mode="$4"
  env PATH="$TEST_ROOT/bin:/usr/bin:/bin" RUNNER_OS=Linux RUNNER_ARCH=X64 \
    GITHUB_WORKSPACE="$TEST_ROOT/workspace" RUNNER_TEMP="$TEST_ROOT" \
    SCAN_TYPE="$scan_type" TARGET="$target" IGNORE_FILE="$ignorefile" \
    FAKE_TRIVY_MODE="$mode" FAKE_TRIVY_LOG="$TEST_ROOT/arguments" \
    bash "$ACTION" "$TEST_ROOT/bin/fake-trivy" > "$TEST_ROOT/output" 2>&1
}

must_succeed() {
  if ! run_action "$@"; then cat "$TEST_ROOT/output"; exit 1; fi
}

must_fail() {
  if run_action "$@"; then printf 'expected failure: %s\n' "$*" >&2; exit 1; fi
}

must_succeed fs . '' clean
grep -Fxq fs "$TEST_ROOT/arguments"
grep -Fxq vuln "$TEST_ROOT/arguments"
grep -Fxq HIGH,CRITICAL "$TEST_ROOT/arguments"
grep -Fxq 1 "$TEST_ROOT/arguments"
grep -Fxq -- --list-all-pkgs "$TEST_ROOT/arguments"

digest="$(printf '%064d' 0)"
image="ghcr.io/example/app@sha256:$digest"
must_succeed image "$image" .trivyignore clean
grep -Fxq image "$TEST_ROOT/arguments"
grep -Fxq "$image" "$TEST_ROOT/arguments"
grep -Fxq "$(realpath -- "$TEST_ROOT/workspace/.trivyignore")" "$TEST_ROOT/arguments"

must_fail fs . '' high
grep -Fq CVE-TEST-1 "$TEST_ROOT/output"
must_fail fs . '' db-error
grep -Fq 'database download failed' "$TEST_ROOT/output"
must_fail fs . '' no-packages
must_fail unknown . '' clean
must_fail fs missing '' clean
must_fail fs ../ '' clean
must_fail image ghcr.io/example/app:latest '' clean
must_fail fs . /etc/passwd clean

if env PATH="$TEST_ROOT/bin:/usr/bin:/bin" RUNNER_OS=macOS RUNNER_ARCH=X64 \
  GITHUB_WORKSPACE="$TEST_ROOT/workspace" RUNNER_TEMP="$TEST_ROOT" \
  SCAN_TYPE=fs TARGET=. IGNORE_FILE='' FAKE_TRIVY_MODE=clean \
  FAKE_TRIVY_LOG="$TEST_ROOT/arguments" bash "$ACTION" "$TEST_ROOT/bin/fake-trivy" > "$TEST_ROOT/output" 2>&1; then
  printf 'expected unsupported platform failure\n' >&2
  exit 1
fi

printf 'trivy-scan behavior tests passed\n'
