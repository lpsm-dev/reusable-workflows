#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "yamllint-check supports Ubuntu x64 only" >&2
  exit 1
fi
test -d "$GITHUB_WORKSPACE"
workspace="$(realpath "$GITHUB_WORKSPACE")"

resolve_workspace_path() {
  local value="$1" result
  if [[ -z "$value" || "$value" == /* ]]; then
    echo "Expected a relative path inside GITHUB_WORKSPACE" >&2
    return 1
  fi
  if [[ ! -e "$workspace/$value" ]]; then
    echo "Path does not exist: $value" >&2
    return 1
  fi
  result="$(realpath "$workspace/$value")"
  case "$result" in
    "$workspace"|"$workspace"/*) printf '%s\n' "$result" ;;
    *) echo "Path escapes GITHUB_WORKSPACE: $value" >&2; return 1 ;;
  esac
}

target="$(resolve_workspace_path "${INPUT_TARGET:-.}")"
if [[ -d "$target" ]]; then
  if ! find "$target" -type f \( -name '*.yaml' -o -name '*.yml' \) -print -quit | grep -q .; then
    echo "No YAML files found under target" >&2
    exit 1
  fi
elif [[ "$target" != *.yaml && "$target" != *.yml ]]; then
  echo "Target must be a YAML file or directory" >&2
  exit 1
fi

args=(--strict --format github)
if [[ -n "${INPUT_CONFIG:-}" ]]; then
  config="$(resolve_workspace_path "$INPUT_CONFIG")"
  if [[ ! -f "$config" ]]; then
    echo "Config must be a file" >&2
    exit 1
  fi
  args+=(-c "$config")
fi
test -x "$RUNNER_TEMP/yamllint-venv/bin/yamllint"
cd "$workspace"
exec "$RUNNER_TEMP/yamllint-venv/bin/yamllint" "${args[@]}" "$target"
