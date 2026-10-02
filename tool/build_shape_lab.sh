#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 tool/validate_shape_masks.py
PLATFORMS=web bash tool/bootstrap.sh

flutter build web \
  --release \
  --pwa-strategy=none \
  --dart-define=CANDY_SOFT_CANDIDATE=true \
  --target shape_lab/main.dart \
  --base-href "/"

rm -rf build/shape_lab
mv build/web build/shape_lab

echo "MY LOCK Crayon Shape Lab build complete: build/shape_lab"

python3 - <<'PYCODE'
import json, os
from pathlib import Path
Path('build/shape_lab/version.json').write_text(json.dumps({
    'commit': os.environ.get('GITHUB_SHA', 'local'),
    'lab_version': 'LAB037',
}))
Path('build/shape_lab/_headers').write_text('/*\n  Cache-Control: no-store, max-age=0\n')
PYCODE
