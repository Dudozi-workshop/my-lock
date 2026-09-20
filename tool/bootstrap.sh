#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required. Install Flutter 3.47.x or newer and retry."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
PLATFORMS="${PLATFORMS:-android,ios}"
trap 'rm -rf "$TMP"' EXIT

cp -R "$ROOT/lib" "$TMP/lib"
cp "$ROOT/pubspec.yaml" "$TMP/pubspec.yaml"
cp "$ROOT/analysis_options.yaml" "$TMP/analysis_options.yaml"
cp -R "$ROOT/test" "$TMP/test"

cd "$ROOT"
flutter create \
  --platforms="$PLATFORMS" \
  --project-name my_lock \
  --org com.mylock.app \
  .

if [[ ",$PLATFORMS," == *",android,"* ]]; then
  bash "$ROOT/tool/apply_android_native.sh"
fi

rm -rf "$ROOT/lib" "$ROOT/test"
cp -R "$TMP/lib" "$ROOT/lib"
cp -R "$TMP/test" "$ROOT/test"
cp "$TMP/pubspec.yaml" "$ROOT/pubspec.yaml"
cp "$TMP/analysis_options.yaml" "$ROOT/analysis_options.yaml"

flutter pub get

# Launcher icon generation is kept outside CI bootstrap.
# A damaged branding source must never block functional APK builds.

flutter analyze
flutter test

echo "MY LOCK bootstrap complete for: $PLATFORMS"
