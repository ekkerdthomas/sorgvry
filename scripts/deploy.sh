#!/usr/bin/env bash
set -euo pipefail

PI_HOST="ekkerdthomas@raspi-webserver"
REMOTE_DIR="/opt/sorgvry"

deploy_backend() {
  echo "==> Checking .env on Pi..."
  ssh "$PI_HOST" "test -f $REMOTE_DIR/.env" || { echo "ERROR: $REMOTE_DIR/.env not found on Pi"; exit 1; }

  # Ensure the updater download dir exists (owned by the ssh/uid-1000 user)
  # BEFORE `docker compose up` bind-mounts it — otherwise Docker root-creates it
  # and the later APK rsync fails with permission denied.
  echo "==> Ensuring download dir exists on Pi..."
  ssh "$PI_HOST" "mkdir -p $REMOTE_DIR/download"

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
  local APK_PATH="app/build/app/outputs/flutter-apk/app-release.apk"
  if [ ! -f "$APK_PATH" ]; then
    echo "ERROR: APK not found at $APK_PATH. Run ./scripts/build.sh apk first."
    exit 1
  fi

  echo "==> Generating version metadata for the in-app updater..."
  local FULL_VERSION VERSION BUILD_NUMBER APK_SIZE APK_SHA BUILD_DATE APK_NAME
  FULL_VERSION=$(grep '^version:' app/pubspec.yaml | sed 's/version: *//')
  VERSION="${FULL_VERSION%%+*}"
  BUILD_NUMBER="${FULL_VERSION#*+}"
  if [ "$BUILD_NUMBER" = "$VERSION" ]; then BUILD_NUMBER=1; fi
  APK_SIZE=$(stat -c%s "$APK_PATH")
  APK_SHA=$(sha256sum "$APK_PATH" | awk '{print $1}')
  BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  # Versioned filename: the manifest points the updater at a per-build APK, so a
  # new binary is never served under an old manifest's sha256 during the deploy
  # window (the manifest and the file it references are always consistent).
  APK_NAME="sorgvry-${VERSION}-${BUILD_NUMBER}.apk"

  local META_DIR="app/build/update"
  mkdir -p "$META_DIR"
  cat > "$META_DIR/version.json" << MANIFEST
{
  "version": "$VERSION",
  "buildNumber": $BUILD_NUMBER,
  "fullVersion": "$FULL_VERSION",
  "releaseDate": "$BUILD_DATE",
  "downloadUrl": "/download/$APK_NAME",
  "fileSizeBytes": $APK_SIZE,
  "sha256": "$APK_SHA",
  "isCriticalUpdate": false,
  "minimumSupportedVersion": "0.1.0+1"
}
MANIFEST

  echo "==> Ensuring download dir exists on Pi..."
  ssh "$PI_HOST" "mkdir -p $REMOTE_DIR/download"

  # Upload the versioned APK FIRST, then the manifest that points at it, so the
  # updater is never told about a version whose binary is not yet in place.
  echo "==> Syncing APK ($APK_NAME) to Pi..."
  rsync -az --checksum \
    "$APK_PATH" \
    "$PI_HOST:$REMOTE_DIR/download/$APK_NAME"
  echo "==> Syncing version.json to Pi..."
  rsync -az \
    "$META_DIR/version.json" \
    "$PI_HOST:$REMOTE_DIR/download/version.json"
  # Also publish under the canonical name for the public /download/sorgvry.apk link.
  echo "==> Updating canonical sorgvry.apk..."
  rsync -az --checksum \
    "$APK_PATH" \
    "$PI_HOST:$REMOTE_DIR/download/sorgvry.apk"
  # Prune old per-build APKs, keeping the 3 most recent — a previously-advertised
  # versioned URL may still be mid-download — so the download dir (which shares
  # the disk with the SQLite data volume) does not grow without bound.
  echo "==> Pruning old versioned APKs (keep last 3)..."
  ssh "$PI_HOST" "cd $REMOTE_DIR/download && ls -t sorgvry-*.apk 2>/dev/null | tail -n +4 | xargs -r rm -f"
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
