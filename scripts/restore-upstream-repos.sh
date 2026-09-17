#!/usr/bin/env bash
# Re-clone the third-party repositories listed in upstream-repos.tsv at their pinned commits.
# They are not committed here because many ship no licence, so they cannot be redistributed.
# Usage: scripts/restore-upstream-repos.sh [path-filter]
#   e.g. scripts/restore-upstream-repos.sh launchpads/doppler
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$root/upstream-repos.tsv"
filter="${1:-}"
failed=0

while IFS=$'\t' read -r path url commit _license; do
  [[ "$path" == "path" ]] && continue
  [[ -n "$filter" && "$path" != "$filter"* ]] && continue

  dest="$root/$path"
  if [[ -d "$dest/.git" ]]; then
    echo "skip   $path (already present)"
    continue
  fi

  echo "clone  $path @ ${commit:0:7}"
  mkdir -p "$(dirname "$dest")"
  if git clone --quiet "$url" "$dest" && git -C "$dest" checkout --quiet "$commit"; then
    continue
  fi
  echo "FAILED $path ($url @ $commit)" >&2
  failed=$((failed + 1))
done < "$manifest"

if (( failed > 0 )); then
  echo "$failed repo(s) could not be restored" >&2
  exit 1
fi
