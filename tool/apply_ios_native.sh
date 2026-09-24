#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$ROOT/ios/Runner/Info.plist"

if [[ ! -f "$PLIST" ]]; then
  echo "iOS Info.plist not found; skipping Flutter GPU opt-in."
  exit 0
fi

python3 - "$PLIST" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

key = '<key>FLTEnableFlutterGPU</key>'
entry = '''	<key>FLTEnableFlutterGPU</key>
	<true/>
'''

if key not in text:
    text = text.replace('</dict>', entry + '</dict>', 1)

path.write_text(text)
PY

echo "Enabled Flutter GPU for iOS."
