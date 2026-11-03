#!/usr/bin/env bash
set -euo pipefail

python3 tool/validate_shape_masks.py
if [ "${ASSET_BOOK_AUTO_SYNC:-0}" = "1" ]; then
  python3 tool/generate_asset_book.py
else
  echo "Asset Book auto-sync paused; using committed frozen snapshot."
fi
PLATFORMS=web bash tool/bootstrap.sh
# BuildStamp metadata comes from the canonical MAIN site registry.
read_main_metadata() {
  python3 - "$1" <<'PY'
import json
import sys
from pathlib import Path

registry = json.loads(Path("config/site_registry.json").read_text(encoding="utf-8"))
print(registry["sites"]["MAIN"][sys.argv[1]])
PY
}
PREVIEW_VERSION="$(read_main_metadata version)"
PREVIEW_PURPOSE="$(read_main_metadata purpose)"
PREVIEW_STATUS="$(read_main_metadata status)"
flutter build web --release --base-href "/" \
  --dart-define=PREVIEW_VERSION="$PREVIEW_VERSION" \
  --dart-define=PREVIEW_PURPOSE="$PREVIEW_PURPOSE" \
  --dart-define=PREVIEW_STATUS="$PREVIEW_STATUS"

# Keep Asset Book as a standalone static viewer alongside the Flutter SPA.
rm -rf build/web/asset-book
mkdir -p build/web
cp -R web/asset-book build/web/asset-book

echo "Flutter Web + Asset Book build complete: build/web"
