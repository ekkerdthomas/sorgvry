#!/usr/bin/env bash
set -euo pipefail

PI_HOST="ekkerdthomas@raspi-webserver"
REMOTE_DIR="/opt/sorgvry"

deploy_backend() {
  echo "==> Checking .env on Pi..."
  ssh "$PI_HOST" "test -f $REMOTE_DIR/.env" || { echo "ERROR: $REMOTE_DIR/.env not found on Pi"; exit 1; }

  echo "==> Syncing backend source to Pi..."
  rsync -az --delete \
    --exclude='.dart_tool' \
    --exclude='.packages' \
    --exclude='build/' \
    --exclude='.git' \
    --exclude='app/' \
    packages backend docker-compose.yml \
    "$PI_HOST:$REMOTE_DIR/src/"

  echo "==> Building and restarting backend on Pi..."
  ssh "$PI_HOST" "cd $REMOTE_DIR/src && docker compose up -d --build sorgvry-backend"
}

deploy_web() {
  echo "==> Syncing web app to Pi..."
  rsync -az --delete \
    app/build/web/ \
    "$PI_HOST:$REMOTE_DIR/web/"
  purge_cloudflare_cache
}

purge_cloudflare_cache() {
  # Read CF credentials from Pi .env
  local cf_zone cf_token
  cf_zone=$(ssh "$PI_HOST" "grep '^CF_ZONE_ID=' $REMOTE_DIR/.env | cut -d= -f2" 2>/dev/null || true)
  cf_token=$(ssh "$PI_HOST" "grep '^CF_API_TOKEN=' $REMOTE_DIR/.env | cut -d= -f2" 2>/dev/null || true)

  if [ -n "$cf_zone" ] && [ -n "$cf_token" ]; then
    echo "==> Purging Cloudflare cache..."
    curl -s -X POST \
      "https://api.cloudflare.com/client/v4/zones/$cf_zone/purge_cache" \
      -H "Authorization: Bearer $cf_token" \
      -H "Content-Type: application/json" \
      -d '{"purge_everything":true}' | grep -o '"success":[a-z]*'
    echo ""
  else
    echo "==> Skipping Cloudflare purge (CF_ZONE_ID/CF_API_TOKEN not set in Pi .env)"
  fi
}

deploy_apk() {
  echo "==> Syncing APK to Pi..."
  rsync -az --checksum \
    app/build/app/outputs/flutter-apk/app-release.apk \
    "$PI_HOST:$REMOTE_DIR/download/sorgvry.apk"
  purge_cloudflare_cache
}

# Parse arguments
TARGETS=("$@")
if [ ${#TARGETS[@]} -eq 0 ]; then
  TARGETS=("all")
fi

for target in "${TARGETS[@]}"; do
  case "$target" in
    backend) deploy_backend ;;
    web)     deploy_web ;;
    apk)     deploy_apk ;;
    all)     deploy_backend; deploy_web; deploy_apk ;;
    *)       echo "Unknown target: $target (use: backend, web, apk, all)"; exit 1 ;;
  esac
done

echo "==> Done."
echo "    Web:      https://sorgvry.phygital-tech.ai/"
echo "    API:      https://sorgvry.phygital-tech.ai/api/health"
echo "    Download: https://sorgvry.phygital-tech.ai/download/sorgvry.apk"
