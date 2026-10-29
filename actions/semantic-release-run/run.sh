#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'semantic-release-run: %s\n' "$1" >&2
  exit 1
}

[[ "${RUNNER_OS:-}" == Linux && "${RUNNER_ARCH:-}" == X64 ]] || fail 'only Linux x64 runners are supported'
[[ -n "${GITHUB_WORKSPACE:-}" && -d "$GITHUB_WORKSPACE" ]] || fail 'GITHUB_WORKSPACE is unavailable'
[[ -n "${GITHUB_TOKEN:-}" ]] || fail 'GITHUB_TOKEN must be supplied through the step environment'
[[ -n "${RELEASE_BRANCH:-}" ]] || fail 'release-branch is required'
case "${DRY_RUN:-}" in
  true) arguments=(--dry-run) ;;
  false) arguments=() ;;
  *) fail 'dry-run must be true or false' ;;
esac
if [[ "${DRY_RUN:-}" == false && "${GITHUB_REF:-}" != "refs/heads/$RELEASE_BRANCH" ]]; then
  fail "publishing is permitted only from refs/heads/$RELEASE_BRANCH"
fi

workspace="$(realpath -- "$GITHUB_WORKSPACE")"
requested="${RELEASE_DIRECTORY:-}"
[[ -n "$requested" && "$requested" != /* ]] || fail 'release-directory must be relative to GITHUB_WORKSPACE'
directory="$(realpath -- "$workspace/$requested")" || fail "release-directory does not exist: $requested"
case "$directory" in
  "$workspace"/*) ;;
  *) fail 'release-directory resolves outside GITHUB_WORKSPACE' ;;
esac
[[ -d "$directory" ]] || fail 'release-directory must be a directory'
for file in package.json package-lock.json .releaserc.json; do
  [[ -f "$directory/$file" ]] || fail "missing release configuration: $file"
  resolved_file="$(realpath -- "$directory/$file")" || fail "cannot resolve release configuration: $file"
  case "$resolved_file" in
    "$workspace"/*) ;;
    *) fail "release configuration resolves outside GITHUB_WORKSPACE: $file" ;;
  esac
done

cd "$directory"
npm ci --ignore-scripts --no-audit --no-fund
[[ -x ./node_modules/.bin/semantic-release ]] || fail 'semantic-release executable is unavailable after npm ci'
./node_modules/.bin/semantic-release "${arguments[@]}"
