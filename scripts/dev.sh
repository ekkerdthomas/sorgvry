#!/usr/bin/env bash
set -euo pipefail

# Start local backend + Flutter app for E2E development
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."

export JWT_SECRET="${JWT_SECRET:-dev-secret-local}"
export DB_PATH="${DB_PATH:-sorgvry.db}"

echo "==> Starting backend on http://localhost:8080..."
cd "$ROOT/backend"
# Run generated server directly — `dart_frog dev` crashes in non-interactive shells
# due to StdinException on echoMode. Regenerate with `dart_frog build` if routes change.
dart run .dart_frog/server.dart &
BACKEND_PID=$!

cleanup() {
  echo "==> Stopping backend (PID $BACKEND_PID)..."
  kill "$BACKEND_PID" 2>/dev/null || true
}
trap cleanup EXIT

sleep 2
echo "==> Backend running (PID $BACKEND_PID)"
echo "==> Starting Flutter app..."
cd "$ROOT/app"
flutter run -d chrome
