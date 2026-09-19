#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID="$ROOT/android"
MAIN_DIR="$ANDROID/app/src/main/kotlin/com/mylock/app/my_lock"
MANIFEST="$ANDROID/app/src/main/AndroidManifest.xml"

mkdir -p "$MAIN_DIR"
cp "$ROOT/platform/android/MainActivity.kt" "$MAIN_DIR/MainActivity.kt"

python3 - "$MANIFEST" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

permissions = [
    '<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />',
    '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />',
]

marker = '<application'
for permission in permissions:
    if permission not in text:
        text = text.replace(marker, f'{permission}\n    {marker}', 1)

path.write_text(text)
PY

echo "Applied MY LOCK Android native bridge."
