#!/usr/bin/env bash
# Usage: tool/mark_slice.sh <slice-id> <done|wip|planned>
set -euo pipefail
cd "$(dirname "$0")/.."
id="$1"
case "$2" in
  done) status='✅ Done' ;;
  wip) status='🚧 In progress' ;;
  planned) status='⬜ Planned' ;;
  *) echo "unknown status $2" >&2; exit 1 ;;
esac
sed -i -E "s/^(\| ${id} \|.*\| )(✅ Done|🚧 In progress|⬜ Planned)( \|)$/\1${status}\3/" PROGRESS.md
grep -qE "^\| ${id} \|.*${status} \|$" PROGRESS.md || { echo "slice ${id} not found" >&2; exit 1; }
tool/update_progress_summary.sh
