// Cloudflare Pages Function: proxies the official Go playground compiler so the
// in-browser Go playground can run real Go (current release) — go.dev sends no
// CORS headers, so the browser cannot call it directly. Same-origin only.
// Request:  POST /api/go-compile  { "body": "<go source>" }
// Response: go.dev's JSON as-is ({ Errors, Events[{Message,Kind,Delay}], VetErrors })
const MAX_SOURCE_BYTES = 64 * 1024;
const UPSTREAM = 'https://go.dev/_/compile';

export const onRequestPost: PagesFunction = async ({ request }) => {
  const origin = request.headers.get('Origin');
  const self = new URL(request.url).origin;
  if (origin && origin !== self) return new Response('forbidden', { status: 403 });

  let source = '';
  try {
    const data = (await request.json()) as { body?: unknown };
    if (typeof data.body !== 'string') throw new Error('body must be a string');
    source = data.body;
  } catch (e) {
    return new Response(`bad request: ${(e as Error).message}`, { status: 400 });
  }
  if (new TextEncoder().encode(source).length > MAX_SOURCE_BYTES) {
    return new Response('source too large', { status: 413 });
  }

  const form = new URLSearchParams({ version: '2', withVet: 'true', body: source });
  const upstream = await fetch(UPSTREAM, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'learn-hub-go-playground/1.0 (+https://avetavos.github.io/learn-hub/)',
    },
    body: form,
    // ponytail: no retry/backoff; the client falls back to the wasm runner on any failure
  });
  if (!upstream.ok) return new Response(`upstream ${upstream.status}`, { status: 502 });
  return new Response(await upstream.text(), {
    status: 200,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' },
  });
};

export const onRequest: PagesFunction = async ({ request }) =>
  request.method === 'POST' ? new Response('unreachable', { status: 500 }) : new Response('method not allowed', { status: 405 });
