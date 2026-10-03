#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "docs" / "public-preview-routes.json"
APP = ROOT / "lib" / "app" / "my_lock_app.dart"

def fail(message: str) -> None:
    raise SystemExit(f"Public preview route validation FAILED: {message}")

data = json.loads(REGISTRY.read_text(encoding="utf-8"))
surfaces = data["surfaces"]
main = surfaces["main_preview"]
labs = surfaces["integrated_labs"]

if "workers.dev" not in main["base_url"]:
    fail("main_preview must use the Worker host")
if "pages.dev" not in labs["base_url"]:
    fail("integrated_labs must use the Pages host")
if main["query_family"] != "qa":
    fail("main_preview query family must be qa")
if labs["query_family"] != "lab":
    fail("integrated_labs query family must be lab")

for name, route in main["routes"].items():
    if not route.startswith("?qa="):
        fail(f"main_preview route {name} is not ?qa=: {route}")
for name, route in labs["routes"].items():
    if not route.startswith("?lab="):
        fail(f"integrated_labs route {name} is not ?lab=: {route}")

app = APP.read_text(encoding="utf-8")
for name, route in main["routes"].items():
    value = route.split("=", 1)[1]
    if value not in app:
        fail(f"main_preview route {name} is not registered in my_lock_app.dart: {value}")

print("Public preview route validation OK")
print(f"Aurora Round 1: {main['base_url']}{main['routes']['aurora_sea_palette_round1']}")
