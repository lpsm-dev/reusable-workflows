#!/usr/bin/env bash
set -euo pipefail

if [[ "${RUNNER_OS:-}" != Linux || "${RUNNER_ARCH:-}" != X64 ]]; then
  echo "commitlint-check supports Ubuntu 24.04 x64 only" >&2
  exit 1
fi

workspace="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
tool_dir="${RUNNER_TEMP:-}/commitlint-check"
bin="${COMMITLINT_BIN:-$tool_dir/node_modules/.bin/commitlint}"
config="$tool_dir/commitlint.config.cjs"
base="${INPUT_BASE_SHA:-}"
head="${INPUT_HEAD_SHA:-}"

if [[ ! -x "$bin" ]]; then
  echo "commitlint executable is missing" >&2
  exit 1
fi
if ! git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "GITHUB_WORKSPACE is not a Git worktree" >&2
  exit 1
fi

if [[ -z "$base" && -z "$head" ]]; then
  git -C "$workspace" log -1 --format=%B HEAD | "$bin" --strict --config "$config"
  exit
fi

if [[ -z "$base" || -z "$head" ]]; then
  echo "base-sha and head-sha must be provided together" >&2
  exit 1
fi
for sha in "$base" "$head"; do
  if [[ ! "$sha" =~ ^[0-9a-fA-F]{40}$ ]] || ! git -C "$workspace" cat-file -e "${sha}^{commit}" 2>/dev/null; then
    echo "base-sha and head-sha must be existing full commit SHAs" >&2
    exit 1
  fi
done

if [[ "$(git -C "$workspace" rev-list --count "${base}..${head}")" == 0 ]]; then
  echo "The commit range has no commits to check" >&2
  exit 1
fi

"$bin" --strict --config "$config" --cwd "$workspace" --from "$base" --to "$head"
