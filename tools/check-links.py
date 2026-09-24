#!/usr/bin/env python3
"""Check that every internal href in a course's built dist/ resolves to a page.

Usage: tools/check-links.py <repo-dir> [<repo-dir> ...]   (run `npx astro build` in each first)
Only hrefs on real tags count (escaped markup shown inside <code> is ignored). Reads `base:` from the repo's astro.config.mjs; any href that starts with "/" must start with that base
and point at an existing file/dir in dist/. Exit 1 if anything is broken.
"""
import glob, os, re, sys

def check(repo):
    cfg = open(os.path.join(repo, 'astro.config.mjs')).read()
    m = re.search(r"base:\s*'([^']+)'", cfg)
    base = (m.group(1) if m else '/').rstrip('/')  # '' when the course is served at the domain root
    dist = os.path.join(repo, 'dist')
    broken = {}
    for f in glob.glob(f'{dist}/**/*.html', recursive=True):
        html = open(f, errors='ignore').read()
        for href in set(re.findall(r'<[a-zA-Z][^<>]*?\shref="(/[^"#?]*)', html)):
            if href.startswith('/_') or href.startswith('/pagefind'):
                continue
            ok = href in (base, base + '/') or href.startswith(base + '/')
            if ok:
                rel = href[len(base):].lstrip('/')
                ok = any(os.path.exists(os.path.join(dist, c)) for c in (rel, rel + '/index.html', rel.rstrip('/') + '.html'))
            if not ok:
                broken.setdefault(href, []).append(os.path.relpath(f, dist))
    print(f'{os.path.basename(repo.rstrip("/"))}: {len(broken)} broken internal hrefs (base {base or "/"})')
    for href, pages in sorted(broken.items()):
        print(f'   {href}  <- {pages[0]}' + (f' (+{len(pages) - 1} more)' if len(pages) > 1 else ''))
    return not broken

if __name__ == '__main__':
    repos = sys.argv[1:] or sys.exit(__doc__)
    sys.exit(0 if all([check(r) for r in repos]) else 1)
