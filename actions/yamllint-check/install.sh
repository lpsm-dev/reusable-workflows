#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "yamllint-check supports Ubuntu x64 only" >&2
  exit 1
fi
venv="$RUNNER_TEMP/yamllint-venv"
python3 -m venv "$venv"
"$venv/bin/pip" install --disable-pip-version-check --no-input \
  --require-hashes --only-binary=:all: -r "$GITHUB_ACTION_PATH/requirements.lock"
"$venv/bin/yamllint" --version
