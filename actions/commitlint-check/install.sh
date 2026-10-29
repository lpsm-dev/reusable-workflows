#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "commitlint-check supports Ubuntu 24.04 x64 only" >&2
  exit 1
fi

tool_dir="${RUNNER_TEMP:?RUNNER_TEMP is required}/commitlint-check"
mkdir -p "$tool_dir"
cp "$GITHUB_ACTION_PATH/package.json" "$GITHUB_ACTION_PATH/package-lock.json" "$GITHUB_ACTION_PATH/commitlint.config.cjs" "$tool_dir/"
npm ci --ignore-scripts --no-audit --no-fund --prefix "$tool_dir"
