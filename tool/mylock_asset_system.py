#!/usr/bin/env python3
"""MY LOCK asset lifecycle bootstrap and validation.

Commands:
  validate [asset_root]
  validate-all [search_root]
  bootstrap <asset_root> --asset-id <id> [--parts a,b,c]

This tool manages metadata and directory scaffolding only. It never edits,
promotes, deletes, or rewrites locked binary assets.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ROOT = ROOT / "assets/shape_masters"
REGISTRY_JSON = "ASSET_REGISTRY.json"
ALLOWED = {"working","candidate","qa_candidate","lock_candidate","final_locked","superseded","withdrawn","archived"}
ID_RE = re.compile(r"^[a-z0-9]+(?:_[a-z0-9]+)*$")
FILE_RE = re.compile(r"^[a-z0-9]+(?:_[a-z0-9]+)*(?:\.[a-z0-9]+)?$")
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
FORBIDDEN_PRODUCTION_TOKENS = ("candidate", "working", "draft", "tmp", "temp", "withdrawn", "legacy")
STANDARD_DIRS = ("master","parts","whole_turtle","runtime","motion","docs","archive")

def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))

def validate(asset_root: Path) -> list[str]:
    errors: list[str] = []
    path = asset_root / REGISTRY_JSON
    if not path.exists():
        return [f"missing registry: {path.relative_to(ROOT)}"]
    try:
        reg = load(path)
    except Exception as exc:
        return [f"invalid registry JSON: {exc}"]

    asset_id = reg.get("asset_id","")
    if not ID_RE.fullmatch(asset_id):
        errors.append(f"invalid asset_id: {asset_id!r}")

    lifecycle = reg.get("lifecycle_vocabulary", [])
    if set(lifecycle) != ALLOWED:
        errors.append("lifecycle_vocabulary must exactly match MY LOCK standard")

    entries = reg.get("lineages", [])
    if not isinstance(entries, list):
        errors.append("lineages must be a list")
        return errors

    active_by_scope: dict[str,int] = {}
    for i, item in enumerate(entries):
        prefix=f"lineages[{i}]"
        scope=item.get("scope","")
        status=item.get("status")
        active=item.get("active")
        if not scope or not all(ID_RE.fullmatch(x) for x in scope.split(".")):
            errors.append(f"{prefix}: invalid scope {scope!r}")
        if status not in ALLOWED:
            errors.append(f"{prefix}: invalid status {status!r}")
        if not isinstance(active,bool):
            errors.append(f"{prefix}: active must be boolean")
        if active:
            active_by_scope[scope]=active_by_scope.get(scope,0)+1
            if status != "final_locked":
                errors.append(f"{prefix}: active=true requires final_locked")
        if status == "final_locked" and active is True and not item.get("user_approved",False):
            errors.append(f"{prefix}: final_locked active lineage requires user_approved=true")

    for scope,count in active_by_scope.items():
        if count != 1:
            errors.append(f"{scope}: expected exactly one active lineage, found {count}")

    scopes = {item.get("scope") for item in entries if item.get("scope")}
    for i, item in enumerate(entries):
        prefix = f"lineages[{i}]"
        derived = item.get("derived_from")
        if derived and derived not in scopes:
            errors.append(f"{prefix}: broken derived_from scope {derived!r}")

        artifact_path = item.get("artifact_path")
        if artifact_path:
            rel = Path(artifact_path)
            if rel.is_absolute() or ".." in rel.parts:
                errors.append(f"{prefix}: artifact_path must stay inside repository")
            else:
                target = ROOT / rel
                if not target.exists():
                    errors.append(f"{prefix}: broken artifact_path {artifact_path!r}")
                if not FILE_RE.fullmatch(rel.name):
                    errors.append(f"{prefix}: filename violates lowercase snake_case grammar: {rel.name!r}")

        source_path = item.get("source_path")
        source_hash = item.get("source_sha256")
        if source_path or source_hash:
            if not source_path or not source_hash:
                errors.append(f"{prefix}: source_path and source_sha256 must be declared together")
            elif not SHA256_RE.fullmatch(str(source_hash)):
                errors.append(f"{prefix}: invalid source_sha256")
            else:
                source = ROOT / source_path
                if not source.is_file():
                    errors.append(f"{prefix}: broken source_path {source_path!r}")
                else:
                    actual = hashlib.sha256(source.read_bytes()).hexdigest()
                    if actual != source_hash:
                        errors.append(f"{prefix}: source hash mismatch for {source_path!r}")

    for rel in reg.get("required_directories", []):
        if not (asset_root / rel).is_dir():
            errors.append(f"missing required directory: {rel}")

    for rel in reg.get("production_directories", []):
        production = asset_root / rel
        if not production.is_dir():
            errors.append(f"missing production directory: {rel}")
            continue
        for item in production.rglob("*"):
            if not item.is_file():
                continue
            normalized = item.name.lower()
            if any(token in normalized for token in FORBIDDEN_PRODUCTION_TOKENS):
                errors.append(
                    f"non-production artifact mixed into production directory: "
                    f"{item.relative_to(asset_root)}"
                )

    return errors

def discover_registries(search_root: Path) -> list[Path]:
    if (search_root / REGISTRY_JSON).is_file():
        return [search_root]
    return sorted(path.parent for path in search_root.rglob(REGISTRY_JSON))

def validate_all(search_root: Path) -> list[str]:
    roots = discover_registries(search_root)
    if not roots:
        return [f"no {REGISTRY_JSON} found under {search_root.relative_to(ROOT)}"]
    errors: list[str] = []
    for asset_root in roots:
        for error in validate(asset_root):
            errors.append(f"{asset_root.relative_to(ROOT)}: {error}")
    return errors

def bootstrap(asset_root: Path, asset_id: str, parts: list[str]) -> None:
    if not ID_RE.fullmatch(asset_id):
        raise SystemExit("asset-id must be lowercase snake_case")
    asset_root.mkdir(parents=True, exist_ok=True)
    for name in STANDARD_DIRS:
        (asset_root/name).mkdir(exist_ok=True)
    for part in parts:
        if not ID_RE.fullmatch(part):
            raise SystemExit(f"invalid part id: {part}")
        (asset_root/"parts"/part).mkdir(parents=True,exist_ok=True)

    path=asset_root/REGISTRY_JSON
    if path.exists():
        raise SystemExit(f"refusing to overwrite existing registry: {path}")
    reg={
      "schema_version":"mylock_asset_registry_v1",
      "asset_id":asset_id,
      "lifecycle_vocabulary":sorted(ALLOWED),
      "required_directories":list(STANDARD_DIRS),
      "lineages":[],
      "policy":{
        "filename_does_not_determine_active_status":True,
        "user_approval_required_for_final_locked":True,
        "locked_binary_overwrite_forbidden":True,
        "archive_before_delete":True
      }
    }
    path.write_text(json.dumps(reg,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(f"bootstrapped {asset_id}: {asset_root.relative_to(ROOT)}")

def main() -> int:
    p=argparse.ArgumentParser()
    sub=p.add_subparsers(dest="cmd",required=True)
    v=sub.add_parser("validate"); v.add_argument("asset_root",nargs="?",default=str(DEFAULT_ROOT))
    va=sub.add_parser("validate-all"); va.add_argument("search_root",nargs="?",default=str(DEFAULT_ROOT))
    b=sub.add_parser("bootstrap"); b.add_argument("asset_root"); b.add_argument("--asset-id",required=True); b.add_argument("--parts",default="")
    a=p.parse_args()
    asset_root=Path(a.asset_root)
    if not asset_root.is_absolute(): asset_root=ROOT/asset_root
    if a.cmd=="bootstrap":
        bootstrap(asset_root,a.asset_id,[x for x in a.parts.split(",") if x]); return 0
    if a.cmd=="validate-all":
        errors=validate_all(asset_root)
    else:
        errors=validate(asset_root)
    if errors:
        print("MY LOCK asset validation FAILED:",file=sys.stderr)
        for e in errors: print(f" - {e}",file=sys.stderr)
        return 1
    print(f"MY LOCK asset validation OK: {asset_root.relative_to(ROOT)}")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
