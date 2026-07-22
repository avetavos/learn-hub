#!/usr/bin/env bash
# Applies Paper read mode to one course repo:
#   1. renames toggle labels in public/enhance.js (Read mode -> Paper mode)
#   2. appends tools/paper-mode.css to src/styles/custom.css (marker-idempotent)
# Usage: apply-paper-mode.sh <repo-dir>
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="${1:?usage: apply-paper-mode.sh <repo-dir>}"
CSS="$REPO/src/styles/custom.css"
JS="$REPO/public/enhance.js"
[ -f "$CSS" ] || { echo "FAIL $REPO: no custom.css" >&2; exit 1; }
[ -f "$JS" ]  || { echo "FAIL $REPO: no enhance.js" >&2; exit 1; }
if ! grep -q 'Paper read mode' "$CSS"; then
  printf '\n' >> "$CSS"
  cat "$HERE/paper-mode.css" >> "$CSS"
fi
sed -i '' -e "s/'Exit read mode'/'Exit paper mode'/g" \
          -e "s/'Read mode'/'Paper mode'/g" "$JS"
echo "OK $REPO"
