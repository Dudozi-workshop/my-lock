#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 tool/validate_shape_masks.py
PLATFORMS=web bash tool/bootstrap.sh

flutter build web \
  --release \
  --target shape_lab/main.dart \
  --base-href "/" \
  --pwa-strategy=none

rm -rf build/shape_lab
mv build/web build/shape_lab

cat > build/shape_lab/_headers <<'EOF'
/index.html
  Cache-Control: no-store, no-cache, must-revalidate
/flutter_service_worker.js
  Cache-Control: no-store
/main.dart.js
  Cache-Control: no-cache, must-revalidate
/*
  Cache-Control: no-cache
EOF

echo "MY LOCK Crayon Shape Lab build complete: build/shape_lab"
