#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
workspace="$tmp/workspace"
bin="$tmp/bin"
mkdir -p "$workspace/.github/workflows" "$bin/yamllint-venv/bin"
printf 'name: fixture\non: push\njobs: {}\n' > "$workspace/.github/workflows/check.yaml"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_log() {
  grep -F -- "$1" "$tmp/log" >/dev/null || fail "expected log fragment: $1"
}

cat > "$bin/actionlint" <<'SH'
#!/usr/bin/env bash
printf 'actionlint %s\n' "$*" > "$TEST_LOG"
exit "$TEST_EXIT"
SH
cat > "$bin/zizmor" <<'SH'
#!/usr/bin/env bash
printf 'zizmor %s\n' "$*" > "$TEST_LOG"
exit "$TEST_EXIT"
SH
cat > "$bin/yamllint-venv/bin/yamllint" <<'SH'
#!/usr/bin/env bash
printf 'yamllint %s\n' "$*" > "$TEST_LOG"
exit "$TEST_EXIT"
SH
cat > "$bin/shellcheck" <<'SH'
#!/usr/bin/env bash
exit 0
SH
chmod +x "$bin/"*
chmod +x "$bin/yamllint-venv/bin/yamllint"

export GITHUB_WORKSPACE="$workspace" RUNNER_TEMP="$bin"
export RUNNER_OS=Linux RUNNER_ARCH=X64 TEST_LOG="$tmp/log" TEST_EXIT=0

bash "$repo/actions/actionlint-check/run.sh"
assert_log 'actionlint -shellcheck='
assert_log "$bin/shellcheck"

bash "$repo/actions/zizmor-audit/run.sh"
assert_log 'zizmor --offline --format github .'

printf 'extends: default\n' > "$workspace/config.yaml"
INPUT_TARGET=. INPUT_CONFIG=config.yaml bash "$repo/actions/yamllint-check/run.sh"
assert_log 'yamllint --strict --format github -c'
assert_log "$workspace/config.yaml"

if INPUT_TARGET=. INPUT_CONFIG=missing.yaml bash "$repo/actions/yamllint-check/run.sh" > "$tmp/out" 2>&1; then
  fail 'missing config must fail'
fi
if INPUT_TARGET=../outside INPUT_CONFIG='' bash "$repo/actions/yamllint-check/run.sh" > "$tmp/out" 2>&1; then
  fail 'target outside workspace must fail'
fi
if RUNNER_OS=macOS bash "$repo/actions/actionlint-check/run.sh" > "$tmp/out" 2>&1; then
  fail 'unsupported platform must fail'
fi
mkdir -p "$workspace/empty"
if INPUT_TARGET=empty INPUT_CONFIG='' bash "$repo/actions/yamllint-check/run.sh" > "$tmp/out" 2>&1; then
  fail 'target without YAML must fail'
fi
status=0
TEST_EXIT=7 bash "$repo/actions/zizmor-audit/run.sh" > "$tmp/out" 2>&1 || status=$?
[[ "$status" == 7 ]] || fail 'zizmor failure must propagate'
status=0
TEST_EXIT=9 bash "$repo/actions/actionlint-check/run.sh" > "$tmp/out" 2>&1 || status=$?
[[ "$status" == 9 ]] || fail 'actionlint failure must propagate'
status=0
TEST_EXIT=11 INPUT_TARGET=. INPUT_CONFIG='' bash "$repo/actions/yamllint-check/run.sh" > "$tmp/out" 2>&1 || status=$?
[[ "$status" == 11 ]] || fail 'yamllint failure must propagate'

printf 'stage 1 action behavior tests passed\n'
