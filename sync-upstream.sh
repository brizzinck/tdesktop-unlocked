#!/usr/bin/env bash
# Sync dev branch with upstream telegramdesktop/tdesktop and re-apply patches.
set -euo pipefail

UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="dev"
PATCHES_DIR="$(dirname "$0")/patches"

echo "==> Fetching upstream..."
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" --no-tags

echo "==> Resetting to upstream/dev..."
git reset --hard "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"

echo "==> Applying patches from $PATCHES_DIR..."
git am --whitespace=nowarn "$PATCHES_DIR"/*.patch

echo "==> Regenerating patches..."
git format-patch "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"..HEAD \
    --output-directory "$PATCHES_DIR" --zero-commit

echo "Done. dev is now $(git log --oneline upstream/dev..HEAD | wc -l | tr -d ' ') commit(s) ahead of upstream."
