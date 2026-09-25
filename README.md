# Learn Hub

A single static landing page that links all 11 interactive technology courses — bilingual (EN/ไทย), with runnable code in the browser.

**Live:** Cloudflare Worker `learn-hub` (learn-hub.avetavos.workers.dev, behind Cloudflare Access) — deploy with `npx wrangler deploy` from this directory

## What's here

- `index.html` — self-contained hub page (inline CSS, no build step, no dependencies).

## The courses it links

**Language Deep Dives** (standalone, language-core): Go, Node.js, Python, Rust.
**For TypeScript Developers** (backend, comparison-first): Go, Python, Rust.
**For React Developers**: Flutter, Svelte, Astro.
**For Designers**: Web for Designers.
**DevOps & Tooling**: Docker — From Zero to Hero.
**Databases**: Redis — From Zero to Hero.

## Deployment

Plain static HTML served as Cloudflare Worker static assets (`wrangler.toml`, assets = this directory). No build step. To update, edit `index.html`, push, then run `npx wrangler deploy`. Course groups deploy separately via `tools/deploy-group.sh <group>` (stages under `~/Develops/.pages-stage/`, outside this repo).
