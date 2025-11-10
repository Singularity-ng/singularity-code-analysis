#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

if git config core.hooksPath >/dev/null; then
  CURRENT=$(git config core.hooksPath)
else
  CURRENT=""
fi

git config core.hooksPath .githooks
chmod -R +x .githooks 2>/dev/null || true

echo "Git hooks configured (core.hooksPath=.githooks)."
