#!/usr/bin/env bash
set -euo pipefail

PLATFORMS=web bash tool/bootstrap.sh
flutter build web --release --base-href "/" \
  --dart-define=BUILD_SHA="${GITHUB_SHA:-local}" \
  --dart-define=BUILD_RUN="${GITHUB_RUN_NUMBER:-dev}" \
  --dart-define=BUILD_LABEL="${BUILD_LABEL:-ShapeSpec-v1}"
echo "Flutter Web build complete: build/web"
