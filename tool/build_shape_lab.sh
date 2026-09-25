#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 tool/validate_shape_masks.py
PLATFORMS=web bash tool/bootstrap.sh

flutter build web \
  --release \
  --target shape_lab/main.dart \
  --base-href "/"

rm -rf build/shape_lab
mv build/web build/shape_lab

echo "MY LOCK Crayon Shape Lab build complete: build/shape_lab"
