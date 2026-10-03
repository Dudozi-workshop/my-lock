#!/usr/bin/env python3
import json
from pathlib import Path

REGISTRY = Path("config/site_registry.json")
EXPECTED = {
    "MAIN": {
        "canonical_url": "https://my-lock-preview.rlatkd5959.workers.dev",
        "deploy_target": "my-lock-preview",
    },
    "LABS": {
        "canonical_url": "https://my-lock-shape-lab-pages.pages.dev",
        "deploy_target": "my-lock-shape-lab-pages",
    },
}

def fail(message: str) -> None:
    raise SystemExit(f"[site-governance] FAIL: {message}")

if not REGISTRY.exists():
    fail(f"missing {REGISTRY}")

data = json.loads(REGISTRY.read_text(encoding="utf-8"))
sites = data.get("sites")
if set(sites or {}) != set(EXPECTED):
    fail("public site registry must contain exactly MAIN and LABS")

for key, expected in EXPECTED.items():
    item = sites[key]
    for field, value in expected.items():
        if item.get(field) != value:
            fail(f"{key}.{field} must be {value!r}")
    for field in ("version", "purpose", "status"):
        if not str(item.get(field, "")).strip():
            fail(f"{key}.{field} is required")

    version = item["version"]
    if not version.startswith(f"{key}-"):
        fail(f"{key}.version must start with {key}-")

print("[site-governance] PASS: exactly two canonical public sites; version/purpose/status present")
