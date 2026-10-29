#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "actionlint-check supports Ubuntu x64 only" >&2
  exit 1
fi
test -d "$GITHUB_WORKSPACE"
workspace="$(realpath "$GITHUB_WORKSPACE")"
if ! find "$workspace/.github/workflows" -maxdepth 1 -type f \
  \( -name '*.yaml' -o -name '*.yml' \) -print -quit 2>/dev/null | grep -q .; then
  echo "No GitHub Actions workflow files found" >&2
  exit 1
fi
test -x "$RUNNER_TEMP/actionlint"
test -x "$RUNNER_TEMP/shellcheck"
cd "$workspace"
exec "$RUNNER_TEMP/actionlint" "-shellcheck=$RUNNER_TEMP/shellcheck" -color
