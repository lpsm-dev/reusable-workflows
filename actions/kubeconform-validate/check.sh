#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Expected the verified Kubeconform executable path" >&2
  exit 2
fi
if [[ ${RUNNER_OS:-} != Linux || ${RUNNER_ARCH:-} != X64 ]]; then
  echo "kubeconform-validate supports Ubuntu x64 runners only" >&2
  exit 2
fi
if [[ ! ${KUBERNETES_VERSION:-} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "kubernetes-version must be a full Kubernetes version, such as 1.29.0" >&2
  exit 2
fi
if [[ -z ${TARGET:-} ]]; then
  echo "target is required" >&2
  exit 2
fi

binary=$1
workspace=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve(strict=True))' "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}")
resolve_path() {
  python3 - "$workspace" "$1" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1]).resolve(strict=True)
candidate = Path(sys.argv[2])
try:
    path = (candidate if candidate.is_absolute() else root / candidate).resolve(strict=True)
except (OSError, RuntimeError) as error:
    print(f"Path does not exist or is invalid: {error}", file=sys.stderr)
    sys.exit(2)
if path != root and root not in path.parents:
    print("Path must be inside GITHUB_WORKSPACE", file=sys.stderr)
    sys.exit(2)
print(path)
PY
}

target=$(resolve_path "$TARGET")
schema_flags=()
if [[ -n ${SCHEMA_PATH:-} ]]; then
  schema=$(resolve_path "$SCHEMA_PATH")
  schema_flags=(-schema-location "$schema" -schema-location default)
fi

files=()
if [[ -f $target ]]; then
  if [[ $target = *.yaml || $target = *.yml ]]; then
    files+=("$target")
  fi
elif [[ -d $target ]]; then
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(find "$target" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0)
fi
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No YAML manifests found in target: $TARGET" >&2
  exit 2
fi

cd "$workspace"
"$binary" -strict -summary -kubernetes-version "$KUBERNETES_VERSION" "${schema_flags[@]}" "${files[@]}"
