#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "zizmor-audit supports Ubuntu x64 only" >&2
  exit 1
fi
test -d "$GITHUB_WORKSPACE"
workspace="$(realpath "$GITHUB_WORKSPACE")"
if ! find "$workspace/.github/workflows" "$workspace/actions" -type f \
  \( -name '*.yaml' -o -name '*.yml' \) -print -quit 2>/dev/null | grep -q .; then
  echo "No GitHub Actions workflow or action files found" >&2
  exit 1
fi
test -x "$RUNNER_TEMP/zizmor"
cd "$workspace"
exec "$RUNNER_TEMP/zizmor" --offline --format github .
