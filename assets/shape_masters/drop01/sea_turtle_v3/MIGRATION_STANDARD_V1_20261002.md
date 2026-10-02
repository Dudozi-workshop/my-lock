# Sea Turtle v3 · Storage Migration Standard v1 — 2026-10-02

## Purpose
First migration case under MY LOCK Standards. This migration normalizes naming and storage only.

## Locked scope
- 2048 Canonical Whole Assembly: no pixel/content changes.
- Part Geometry / Material / Ownership: no changes.
- Runtime v3 remains downstream Derived Asset work.
- No ImageGen.
- No lifecycle promotion is implied by moving or renaming a file.

## Source of Truth
- GitHub main Manifest: active production lineage.
- Notion Asset Master / Standards: decision and specification record.
- Google Drive: binary master / QA / package storage.

## Target Drive structure
```
02 Sea Turtle/
  master/
  parts/
    body_with_rear/
    shell/
    underbelly/
    front_flipper_near/
    front_flipper_far/
  whole_turtle/
  runtime/
  motion/
  docs/
  archive/
```

## Classification
Every existing object must be classified before migration:
- ACTIVE_KEEP
- RENAME_MOVE
- SUPERSEDED_ARCHIVE
- WITHDRAWN_ARCHIVE
- TEMP_DUPLICATE_REVIEW

## Naming
Lowercase snake_case.

Preferred asset grammar:
```
{asset_id}_{part_id}_{layer_id}_{artifact_type}_{state}_v{revision}_{size}.{ext}
```

Lifecycle truth remains in Manifest. Filename tokens do not independently establish Active status.

## Safety
1. Preserve Drive file IDs when renaming/moving.
2. Never overwrite locked source binaries.
3. Never delete ambiguous duplicates during migration.
4. Verify GitHub/Notion references after each migration batch.
5. Stop on lineage conflict.
6. Archive before deletion.
7. Only one active lineage per scope.

## Batch order
1. Create target directory skeleton.
2. Canonical Master / active Part packages.
3. Whole Canonical Assembly.
4. Runtime derived assets.
5. QA/history.
6. Superseded/withdrawn/legacy packages.
7. Temp/duplicate review.
8. Reference and manifest QA.

## Current preflight
- Latest main checked before migration.
- Runtime v3 handoff checked.
- Drop 01 Asset Master checked.
- Q3 Whole Canonical and Part locks remain authoritative.
