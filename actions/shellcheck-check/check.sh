#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Expected the verified ShellCheck executable path" >&2
  exit 2
fi
if [[ ${RUNNER_OS:-} != Linux || ${RUNNER_ARCH:-} != X64 ]]; then
  echo "shellcheck-check supports Ubuntu x64 runners only" >&2
  exit 2
fi

binary=$1
workspace=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve(strict=True))' "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}")
target=${TARGET:-.}
resolved=$(python3 - "$workspace" "$target" <<'PY'
import os
from pathlib import Path
import sys

root = Path(sys.argv[1]).resolve(strict=True)
candidate = Path(sys.argv[2])
try:
    path = (candidate if candidate.is_absolute() else root / candidate).resolve(strict=True)
except (OSError, RuntimeError) as error:
    print(f"Target does not exist or is invalid: {error}", file=sys.stderr)
    sys.exit(2)
if path != root and root not in path.parents:
    print("Target must be inside GITHUB_WORKSPACE", file=sys.stderr)
    sys.exit(2)
print(path)
PY
)

files=()
if [[ -f $resolved ]]; then
  files+=("$resolved")
elif [[ -d $resolved ]]; then
  if ! git -C "$workspace" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Directory scanning requires a Git checkout" >&2
    exit 2
  fi
  while IFS= read -r -d '' relative; do
    file="$workspace/$relative"
    if [[ ! -f $file || -L $file || $file != "$resolved"/* ]]; then
      continue
    fi
    name=${file##*/}
    if [[ $name = *.sh || $name = *.bash || $name = *.dash ]]; then
      files+=("$file")
      continue
    fi
    IFS= read -r first < "$file" || true
    if [[ $first =~ ^#!.*[[:space:]/](sh|bash|dash|ksh|ash)([[:space:]]|$) ]]; then
      files+=("$file")
    fi
  done < <(git -C "$workspace" ls-files -z)
fi

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No Shell scripts found in target: $target" >&2
  exit 2
fi
cd "$workspace"
"$binary" -f gcc -- "${files[@]}"
