#!/usr/bin/env bash
set -euo pipefail

python3 tool/validate_shape_masks.py
PLATFORMS=web bash tool/bootstrap.sh
PREVIEW_VERSION="$(tr -d '[:space:]' < tool/preview_version.txt)"
flutter build web --release --base-href "/" \
  --dart-define=PREVIEW_VERSION="$PREVIEW_VERSION"
echo "Flutter Web build complete: build/web"
