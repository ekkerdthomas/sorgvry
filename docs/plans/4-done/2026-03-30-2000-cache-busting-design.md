# Cache Busting on Redeploy — Design

**Date**: 2026-03-30
**Status**: Draft
**Trigger**: Stale web app after deploy — browser and Cloudflare serve cached index.html

## Problem

After deploying a new web build, users see the old version until they hard-refresh. Two caching layers cause this:

1. **Browser**: Caches `index.html` with no revalidation directive
2. **Cloudflare CDN**: Caches all static files with default TTL, not purged on deploy

Flutter's hashed asset filenames (e.g. `main.abc123.js`) handle asset cache-busting, but `index.html` — which references those assets — gets stale.

## Solution

### 1. Nginx cache headers (on Pi)

Add cache directives to the sorgvry nginx config:

- `index.html` and `/`: `Cache-Control: no-cache` (browser always revalidates with server)
- Hashed assets (`*.js`, `*.css`, `*.woff2`): `Cache-Control: public, max-age=31536000, immutable` (cache forever — hash changes on new build)

### 2. Cloudflare cache purge in deploy.sh

After web rsync completes, call the Cloudflare API to purge the entire zone cache:

```bash
purge_cloudflare_cache() {
  if [ -n "$CF_ZONE_ID" ] && [ -n "$CF_API_TOKEN" ]; then
    echo "==> Purging Cloudflare cache..."
    curl -s -X POST \
      "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/purge_cache" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"purge_everything":true}'
    echo ""
  else
    echo "==> Skipping Cloudflare purge (CF_ZONE_ID/CF_API_TOKEN not set)"
  fi
}
```

### 3. Secrets storage

Add `CF_ZONE_ID` and `CF_API_TOKEN` to the existing `.env` on the Pi at `/opt/sorgvry/.env`. The deploy script already SSHes to the Pi, so it can source the env file before purging.

## Files Touched

| File | Change |
|------|--------|
| `scripts/deploy.sh` | Add `purge_cloudflare_cache()`, source Pi .env, call after web deploy |
| Pi: nginx config | Add cache-control headers for index.html and static assets |
| Pi: `/opt/sorgvry/.env` | Add `CF_ZONE_ID` and `CF_API_TOKEN` |

## Setup Steps (one-time, on Pi)

1. Create a Cloudflare API token with `Zone.Cache Purge` permission
2. Find the zone ID from Cloudflare dashboard (Overview page)
3. Add both to `/opt/sorgvry/.env`
4. Update nginx config and `sudo nginx -s reload`

## Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Cache strategy | no-cache for HTML, immutable for hashed assets | Best of both: always fresh HTML, zero-latency assets |
| CF purge | purge_everything on every deploy | Simple, low frequency (~1/day), covers all paths |
| Secrets | .env on Pi | Already used for DB/JWT/MinIO, keeps secrets off dev machine |
