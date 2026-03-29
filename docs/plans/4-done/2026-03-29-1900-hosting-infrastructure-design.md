---
title: Sorgvry Hosting Infrastructure
date: 2026-03-29
status: draft
---

# Sorgvry Hosting Infrastructure

Hosting plan for the Dart Frog backend on `raspi-webserver` via Cloudflare tunnel.

## Overview

```
Internet → Cloudflare CDN/SSL
         → cloudflared tunnel (phygital-tech.ai)
         → nginx:80 (server_name sorgvry.phygital-tech.ai)
         → 127.0.0.1:8600
         → Dart Frog Docker container
              ↕
         /opt/sorgvry/data/sorgvry.db (bind mount)
```

**Domain:** `sorgvry.phygital-tech.ai`
**Host:** `ekkerdthomas@raspi-webserver` (Tailscale SSH)
**Port:** 8600 (host) → 8080 (container, Dart Frog default)

## 1. Docker Setup

### Dockerfile (in `backend/`)

Multi-stage build:
1. **Build stage**: Use `dart:stable` image, resolve deps, compile Dart Frog to native binary
2. **Run stage**: Minimal `debian:slim` image, copy binary + SQLite libs, expose 8080

```dockerfile
# Build stage
FROM dart:stable AS build
WORKDIR /app
COPY packages/sorgvry_shared/ packages/sorgvry_shared/
COPY backend/ backend/
WORKDIR /app/backend
RUN dart pub get
RUN dart_frog build
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Run stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libsqlite3-0 && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/backend/build/bin/server /app/server
EXPOSE 8080
ENV PORT=8080
CMD ["/app/server"]
```

> Note: The exact Dart Frog build output path may differ — verify with `dart_frog build` output.

### docker-compose.yml (in project root or `infra/`)

```yaml
services:
  sorgvry-backend:
    build:
      context: .
      dockerfile: backend/Dockerfile
    container_name: sorgvry-backend
    restart: unless-stopped
    ports:
      - "127.0.0.1:8600:8080"
    volumes:
      - /opt/sorgvry/data:/app/data
    env_file:
      - /opt/sorgvry/.env
    environment:
      - DB_PATH=/app/data/sorgvry.db
```

## 2. Nginx Configuration (one-time manual setup)

Add to `/etc/nginx/sites-available/sorgvry`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name sorgvry.phygital-tech.ai;
    include /etc/nginx/security-headers.conf;

    access_log /var/log/nginx/sorgvry-access.log;
    error_log /var/log/nginx/sorgvry-error.log;

    location / {
        proxy_pass http://127.0.0.1:8600;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_connect_timeout 90;
    }
}
```

Then:
```bash
sudo ln -s /etc/nginx/sites-available/sorgvry /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

## 3. Cloudflare Tunnel (one-time manual setup)

Add to `/etc/cloudflared/phygital-tech.yml` before the catch-all `http_status:404`:

```yaml
  - hostname: sorgvry.phygital-tech.ai
    service: http://localhost:80
```

Add DNS record in Cloudflare dashboard:
- Type: CNAME
- Name: `sorgvry`
- Target: `0243bc0a-63fe-4716-bc2f-8d5f7c48f7b9.cfargotunnel.com`
- Proxied: Yes

Then restart cloudflared:
```bash
sudo systemctl restart cloudflared
```

## 4. Environment Variables

Create `/opt/sorgvry/.env` on the Pi (not in repo):

```env
JWT_SECRET=<generate-strong-secret>
DB_PATH=/app/data/sorgvry.db
# Email config for daily summary (see spec §7)
EMAIL_SMTP_HOST=
EMAIL_SMTP_PORT=
EMAIL_FROM=
EMAIL_TO=
EMAIL_PASSWORD=
```

## 5. Deploy Script

`deploy.sh` in project root — Docker-only deployment:

```bash
#!/usr/bin/env bash
set -euo pipefail

PI_HOST="ekkerdthomas@raspi-webserver"
REMOTE_DIR="/opt/sorgvry"

echo "==> Syncing source to Pi..."
rsync -az --delete \
  --exclude='.dart_tool' \
  --exclude='.packages' \
  --exclude='build/' \
  --exclude='.git' \
  --exclude='app/' \
  packages/ backend/ docker-compose.yml backend/Dockerfile \
  "$PI_HOST:$REMOTE_DIR/src/"

echo "==> Building and restarting on Pi..."
ssh "$PI_HOST" "cd $REMOTE_DIR/src && docker compose up -d --build sorgvry-backend"

echo "==> Done. Check: curl https://sorgvry.phygital-tech.ai/health"
```

## 6. Initial Pi Setup Checklist

One-time setup on `raspi-webserver`:

- [ ] Create directories: `sudo mkdir -p /opt/sorgvry/{data,src}`
- [ ] Set ownership: `sudo chown -R ekkerdthomas:ekkerdthomas /opt/sorgvry`
- [ ] Create `/opt/sorgvry/.env` with secrets
- [ ] Add nginx server block (§2 above)
- [ ] Enable nginx site and reload
- [ ] Add cloudflared ingress entry (§3 above)
- [ ] Add Cloudflare DNS CNAME record
- [ ] Restart cloudflared
- [ ] Run first deploy: `./deploy.sh`
- [ ] Verify: `curl https://sorgvry.phygital-tech.ai/health`

## 7. App Base URL Update

Update the spec's base URL from `http://sorgvry.local:8080` to:

- **Production:** `https://sorgvry.phygital-tech.ai`
- **Local dev:** `http://localhost:8080` (running `dart_frog dev` locally)

The app should read this from a config/environment variable.

## Decisions Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Routing | Tunnel → nginx → Docker | Consistent with existing Pi services, enables access logs and rate limiting |
| Host port | 8600 | Follows existing convention (8200-8500 taken) |
| DB storage | Bind mount `/opt/sorgvry/data` | Easy backup, survives container rebuilds |
| Deploy method | SSH + rsync + docker compose | Simple, no CI needed during development |
| Nginx/CF setup | Manual one-time | Only changes if adding subdomains; not worth automating |
