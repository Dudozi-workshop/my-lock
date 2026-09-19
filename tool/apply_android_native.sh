#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID="$ROOT/android"
MAIN_DIR="$ANDROID/app/src/main/kotlin/com/mylock/app/my_lock"
MANIFEST="$ANDROID/app/src/main/AndroidManifest.xml"
mkdir -p "$MAIN_DIR"
cp "$ROOT/platform/android/MainActivity.kt" "$MAIN_DIR/MainActivity.kt"
cp "$ROOT/platform/android/LockActivity.kt" "$MAIN_DIR/LockActivity.kt"
cp "$ROOT/platform/android/LockMonitorService.kt" "$MAIN_DIR/LockMonitorService.kt"
cp "$ROOT/platform/android/BootReceiver.kt" "$MAIN_DIR/BootReceiver.kt"

python3 - "$MANIFEST" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

text = text.replace('android:label="my_lock"', 'android:label="MY LOCK"')

permissions = [
    '<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />',
    '<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />',
    '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />',
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />',
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />',
    '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
    '<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />',
]

marker = '<application'
for permission in permissions:
    if permission not in text:
        text = text.replace(marker, f'{permission}\n    {marker}', 1)

queries = '''    <queries>
        <intent>
            <action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" />
        </intent>
    </queries>
'''

if '<queries>' not in text:
    text = text.replace('<application', queries + '    <application', 1)

lock_activity = '''        <activity
            android:name=".LockActivity"
            android:exported="false"
            android:excludeFromRecents="true"
            android:noHistory="true"
            android:launchMode="standard"
            android:taskAffinity="${applicationId}.lock"
            android:theme="@style/LaunchTheme"
            android:windowSoftInputMode="adjustResize" />
'''

if 'android:name=".LockActivity"' not in text:
    text = text.replace('</application>', lock_activity + '    </application>', 1)

service = '''        <service
            android:name=".LockMonitorService"
            android:enabled="true"
            android:exported="false"
            android:stopWithTask="false"
            android:foregroundServiceType="specialUse">
            <property
                android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
                android:value="Monitors user-selected protected apps to present the MY LOCK screen." />
        </service>
'''

if 'android:name=".LockMonitorService"' not in text:
    text = text.replace('</application>', service + '    </application>', 1)

receiver = '''        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>
'''

if 'android:name=".BootReceiver"' not in text:
    text = text.replace('</application>', receiver + '    </application>', 1)

path.write_text(text)
PY


echo "Applied MY LOCK Android native bridge."
