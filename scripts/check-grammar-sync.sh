#!/usr/bin/env bash
set -euo pipefail

QUIET=0
if [[ ${1:-} == "--quiet" ]]; then
  QUIET=1
  shift
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

if [ ! -d "$REPO_ROOT/enums" ]; then
  if [ "$QUIET" -ne 1 ]; then
    echo "Skipping grammar sync check: enums crate not present." >&2
  fi
  exit 0
fi

./scripts/recreate-grammars.sh

if ! git diff --quiet -- src/languages src/c_langs_macros; then
  echo "Generated grammar enums are out of date."
  echo "Run ./scripts/recreate-grammars.sh locally and commit the changes." >&2
  git status --short src/languages src/c_langs_macros
  exit 1
fi

if [ "$QUIET" -ne 1 ]; then
  echo "Grammar enums are up to date."
fi
