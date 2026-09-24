#!/usr/bin/env bash
# Refreshes the summary block of PROGRESS.md and the coverage table of README.md from the
# status column of PROGRESS.md.
set -euo pipefail
cd "$(dirname "$0")/.."
total=$(grep -cE '^\| [A-Z][0-9]+ \|' PROGRESS.md)
done_count=$(grep -cE '^\| [A-Z][0-9]+ \|.*✅ Done \|$' PROGRESS.md || true)
wip=$(grep -cE '^\| [A-Z][0-9]+ \|.*🚧 In progress \|$' PROGRESS.md || true)
summary="**${done_count} of ${total} slices done**, ${wip} in progress."
awk -v s="$summary" '
  /<!-- summary:start -->/ { print; print s; skip=1; next }
  /<!-- summary:end -->/ { skip=0 }
  !skip { print }
' PROGRESS.md > PROGRESS.md.tmp && mv PROGRESS.md.tmp PROGRESS.md

table=$(awk '
  /^## / && !/^## Summary/ { phase=substr($0, 4); if (!(phase in seen)) { order[++n]=phase; seen[phase]=1 } next }
  /^\| [A-Z][0-9]+ \|/ { total[phase]++; if ($0 ~ /✅ Done \|$/) done[phase]++ }
  END {
    print "| Area | Done | Total |"
    print "| --- | --- | --- |"
    for (i = 1; i <= n; i++) { p=order[i]; printf "| %s | %d | %d |\n", p, done[p]+0, total[p] }
  }
' PROGRESS.md)
awk -v t="$table" -v s="$summary" '
  /<!-- coverage:start -->/ { print; print s; print ""; print t; skip=1; next }
  /<!-- coverage:end -->/ { skip=0 }
  !skip { print }
' README.md > README.md.tmp && mv README.md.tmp README.md
