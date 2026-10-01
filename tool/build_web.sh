#!/usr/bin/env bash
set -euo pipefail

python3 tool/validate_shape_masks.py
python3 tool/generate_asset_book.py
PLATFORMS=web bash tool/bootstrap.sh
PREVIEW_VERSION="$(tr -d '[:space:]' < tool/preview_version.txt)"
flutter build web --release --base-href "/" \
  --dart-define=PREVIEW_VERSION="$PREVIEW_VERSION"

# Keep Asset Book as a standalone static viewer alongside the Flutter SPA.
rm -rf build/web/asset-book
mkdir -p build/web
cp -R web/asset-book build/web/asset-book

echo "Flutter Web + Asset Book build complete: build/web"
