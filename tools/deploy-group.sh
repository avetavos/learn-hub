#!/usr/bin/env bash
# Builds every course in a group and deploys the group's Cloudflare Pages
# project (production). Slug per course comes from its astro.config.mjs base.
# Files over Cloudflare Pages' 25 MiB limit are stripped from staging: the
# 38 MB go-runner.wasm is served from GitHub Releases, not Pages.
# Usage: deploy-group.sh <group>
set -euo pipefail
ROOT="$HOME/Develops"
GROUP="${1:?usage: deploy-group.sh <group>}"
case "$GROUP" in
  deep-dive) MEMBERS="astro-deep-dive datadog-deep-dive flutter-deep-dive go-deep-dive kafka-deep-dive kubernetes-deep-dive nextjs-deep-dive nodejs-deep-dive python-deep-dive react-deep-dive rust-deep-dive supabase-deep-dive svelte-deep-dive terraform-terragrunt-aws-deep-dive terraform-terragrunt-azure-deep-dive terraform-terragrunt-gcp-deep-dive typescript-deep-dive";;
  devops-tools) MEMBERS="docker-from-zero-to-hero growthbook-from-zero-to-hero keycloak-from-zero-to-hero rabbitmq-from-zero-to-hero redis-from-zero-to-hero";;
  software-design) MEMBERS="design-patterns-from-zero-to-hero graphql-design-from-zero-to-hero grpc-design-from-zero-to-hero microservices-design-from-zero-to-hero refactoring-from-zero-to-hero rest-api-design-from-zero-to-hero websocket-design-from-zero-to-hero";;
  databases) MEMBERS="mongodb-from-zero-to-hero postgresql-from-zero-to-hero";;
  for-typescript-developers) MEMBERS="go-for-typescript-developers python-for-typescript-developers rust-for-typescript-developers";;
  for-react-developers) MEMBERS="astro-for-react-developers flutter-for-react-developers svelte-for-react-developers";;
  web-platform) MEMBERS="browser-storage-from-zero-to-hero pwa-from-zero-to-hero web-components-from-zero-to-hero webassembly-from-zero-to-hero";;
  web-for-designers) MEMBERS="web-for-designers";;
  *) echo "unknown group: $GROUP" >&2; exit 1;;
esac
STAGE="$ROOT/learn-hub/.pages-stage/$GROUP"
rm -rf "$STAGE"; mkdir -p "$STAGE"
for repo in $MEMBERS; do
  echo "==== build $repo"
  ( cd "$ROOT/$repo" && npm run build )
  base="$(grep -oE "base: '[^']+'" "$ROOT/$repo/astro.config.mjs" | cut -d"'" -f2 || true)"
  base="${base#/}"
  dest="$STAGE${base:+/$base}"
  mkdir -p "$dest"
  cp -R "$ROOT/$repo/dist/." "$dest/"
done
echo "==== stripping files over the 25 MiB Pages limit:"
find "$STAGE" -type f -size +25M -print -delete
( cd "$ROOT/learn-hub" \
  && npx wrangler pages deploy "$STAGE" --project-name="$GROUP" --branch=main --commit-dirty=true )
