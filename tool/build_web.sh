#!/usr/bin/env bash
set -euo pipefail

PLATFORMS=web bash tool/bootstrap.sh
flutter build web --release --base-href "/"
echo "Flutter Web build complete: build/web"
