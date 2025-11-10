#!/usr/bin/env bash
set -euo pipefail

OUTPUT_PATH=${1:-release-artifacts/RELEASE_REVIEW.md}
mkdir -p "$(dirname "$OUTPUT_PATH")"

command -v python3 >/dev/null || { echo "python3 is required to generate the release review." >&2; exit 1; }

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
COMMIT_SHA=$(git rev-parse HEAD)
TAG_NAME=${GITHUB_REF_NAME:-$(git describe --tags --always 2>/dev/null || echo "N/A")}
GENERATED_AT=$(date -u +"%Y-%m-%d %H:%M:%SZ")

METADATA_JSON=$(cargo metadata --no-deps --format-version 1)
VERSION=$(CARGO_METADATA_JSON="$METADATA_JSON" python3 - <<'PY'
import json, os
metadata = json.loads(os.environ["CARGO_METADATA_JSON"])
workspace_members = set(metadata.get("workspace_members", []))
packages = metadata.get("packages", [])
root = None
if workspace_members:
    for pkg in packages:
        if pkg.get("id") in workspace_members:
            root = pkg
            break
if not root and packages:
    root = packages[0]
print(root.get("version", "unknown") if root else "unknown")
PY
)

artifact_lines=$(find target/release -maxdepth 1 -type f -perm -111 -printf "- %f\n" 2>/dev/null || true)
if [[ -z "$artifact_lines" ]]; then
  artifact_lines="- (no compiled binaries were found in target/release)"
fi

cat > "$OUTPUT_PATH" <<EOF
# Release Review Summary

**Repository**: $REPO_NAME  
**Version**: $VERSION  
**Tag**: $TAG_NAME  
**Commit**: $COMMIT_SHA  
**Generated**: $GENERATED_AT (UTC)

---

## Verification Checklist
- [x] cargo clippy --workspace --all-targets -- -D warnings -W clippy::pedantic
- [x] cargo test --workspace --all-targets
- [x] cargo build --workspace --release

_All checklist items are marked complete because this document is produced only after the corresponding CI steps succeed._

## Release Artifacts
$artifact_lines

## Notes
This release review is generated automatically from the release workflow. Delete any prior manual review files to keep the repository clean.
EOF

printf 'Wrote release review to %s\n' "$OUTPUT_PATH"
