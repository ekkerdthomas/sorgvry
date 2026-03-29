#!/usr/bin/env bash
set -euo pipefail

# Publish a sanitized copy of this repo to the public remote.
# Usage:
#   ./scripts/publish.sh              # publish to public remote
#   ./scripts/publish.sh --dry-run    # preview without pushing
#
# Setup (one-time):
#   git remote add public git@github.com:YOUR_ORG/sorgvry.git

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."
DRY_RUN=false
PUBLIC_REMOTE="public"
PUBLIC_BRANCH="main"

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

cd "$ROOT"

# --- Validate ---
if ! git remote get-url "$PUBLIC_REMOTE" &>/dev/null; then
  echo "ERROR: Remote '$PUBLIC_REMOTE' not configured."
  echo "Run:  git remote add $PUBLIC_REMOTE git@github.com:YOUR_ORG/sorgvry.git"
  exit 1
fi

# --- Prepare worktree ---
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> Copying public files to $WORK_DIR..."

# Directories to include (recursively)
INCLUDE_DIRS=(
  app
  backend
  packages
)

# Individual files to include
INCLUDE_FILES=(
  CLAUDE.md
  README.md
  docker-compose.yml
  melos.yaml
  pubspec.yaml
  .gitignore
  docs/sorgvry-spec.md
  scripts/build.sh
  scripts/dev.sh
)

# Copy directories
for dir in "${INCLUDE_DIRS[@]}"; do
  rsync -a --exclude='.dart_tool' --exclude='build/' --exclude='.packages' \
    --exclude='*.db' --exclude='.idea' --exclude='*.jks' --exclude='key.properties' \
    --exclude='.gradle' --exclude='local.properties' --exclude='*.iml' \
    --exclude='.vscode' --exclude='.flutter-plugins-dependencies' --exclude='.metadata' \
    "$dir/" "$WORK_DIR/$dir/"
done

# Copy individual files (preserving directory structure)
for file in "${INCLUDE_FILES[@]}"; do
  mkdir -p "$WORK_DIR/$(dirname "$file")"
  cp "$file" "$WORK_DIR/$file"
done

# --- Scrub personal info ---
echo "==> Scrubbing personal information..."

scrub() {
  local find="$1" replace="$2"
  local files
  files=$(grep -rl "$find" "$WORK_DIR" 2>/dev/null || true)
  [ -z "$files" ] && return 0
  echo "$files" | while read -r f; do
    sed -i "s|$find|$replace|g" "$f"
  done
}

scrub "Amanda Thomas"                              "Your Patient Name"
scrub "ekkerdthomas@raspi-webserver"               "user@your-server"
scrub "raspi-webserver"                            "your-server"
scrub "sorgvry.phygital-tech.ai"                   "your-domain.example.com"
scrub "0243bc0a-63fe-4716-bc2f-8d5f7c48f7b9"       "your-tunnel-uuid"
scrub "ekkerd@\\.\\.\\.,"                          "you@example.com,"

# Scrub "Amanda" in code/doc contexts
scrub "Amanda" "Patient"

# Replace specific .claude/ entries with a blanket exclusion
sed -i '/^\.claude\//d' "$WORK_DIR/.gitignore"
printf '\n# Claude Code (private)\n.claude/\n' >> "$WORK_DIR/.gitignore"

# --- Generate LICENSE (MIT) ---
cat > "$WORK_DIR/LICENSE" << 'LICEOF'
MIT License

Copyright (c) 2026 Sorgvry Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICEOF

# --- Verify no leaks ---
echo "==> Checking for remaining personal info..."
LEAKED=false
for pattern in "Amanda Thomas" "ekkerdthomas" "raspi-webserver"; do
  if grep -rl "$pattern" "$WORK_DIR" 2>/dev/null | head -1; then
    echo "WARNING: '$pattern' still found in public files!"
    LEAKED=true
  fi
done
if $LEAKED; then
  echo "ERROR: Personal info leak detected. Aborting."
  exit 1
fi

echo "==> Scrub clean."

# --- Dry run stops here ---
if $DRY_RUN; then
  echo ""
  echo "==> DRY RUN — files prepared in: $WORK_DIR"
  echo "    Inspect with: ls -la $WORK_DIR"
  echo ""
  echo "Files that would be published:"
  find "$WORK_DIR" -type f | sed "s|$WORK_DIR/||" | sort
  # Keep the temp dir for inspection
  trap - EXIT
  echo ""
  echo "    Remember to clean up: rm -rf $WORK_DIR"
  exit 0
fi

# --- Commit and push ---
cd "$WORK_DIR"
git init -q
git checkout -q -b "$PUBLIC_BRANCH"
git add -A
git commit -q -m "Publish from $(cd "$ROOT" && git rev-parse --short HEAD)"

git remote add "$PUBLIC_REMOTE" "$(cd "$ROOT" && git remote get-url "$PUBLIC_REMOTE")"
echo "==> Pushing to $PUBLIC_REMOTE/$PUBLIC_BRANCH..."
git push -f "$PUBLIC_REMOTE" "$PUBLIC_BRANCH"

echo "==> Published successfully."
echo ""
echo "To pull community changes back:"
echo "  git fetch $PUBLIC_REMOTE"
echo "  git merge $PUBLIC_REMOTE/$PUBLIC_BRANCH"
