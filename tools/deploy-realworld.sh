#!/usr/bin/env bash
# Deploy the Real-World Projects series (projects.avetavos.com/<slug>/*).
# Each repo owns a Cloudflare Worker + route and deploys itself via `npm run deploy`
# (astro build -> .cf-assets/<slug> -> wrangler deploy). taskflow also holds the
# custom domain. Usage: tools/deploy-realworld.sh [slug ...]   (default: all seven)
set -euo pipefail
ROOT="$HOME/Develops"
SLUGS=("$@"); [ ${#SLUGS[@]} -eq 0 ] && SLUGS=(taskflow devblog shopmicro fittrack mosaic offlinenotes clouddeploy)
for s in "${SLUGS[@]}"; do
  echo "== realworld-$s"
  ( cd "$ROOT/realworld-$s" && npm run -s deploy 2>&1 | grep -E "Deployed|Uploaded|error|Error" | tail -3 )
  code=$(curl -s -o /dev/null -w '%{http_code}' "https://projects.avetavos.com/$s/en/")
  echo "   https://projects.avetavos.com/$s/en/ -> $code"
done
