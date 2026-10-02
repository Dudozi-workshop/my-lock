# Sea Turtle v3 · Asset Registry v1

Status: Active registry  
Purpose: normalized lifecycle index. Existing historical manifests remain immutable.

## Canonical
- Asset ID: `sea_turtle_v3`
- Authoritative Master: Q3 Canonical Master
- Canonical Canvas: 2048 x 2048 RGBA
- Filename alone never determines lifecycle status.

## Normalized lifecycle vocabulary
`working / candidate / qa_candidate / lock_candidate / final_locked / superseded / withdrawn / archived`

`active` is tracked separately from lifecycle status.

## Active lineages
| Scope | Revision | Status | Active |
|---|---|---|---|
| shell_main | current locked lineage | final_locked | true |
| body_with_rear geometry | FINAL_v2 | final_locked | true |
| body_with_rear outline | FINAL_v3 | final_locked | true |
| underbelly geometry | FINAL_v4 | final_locked | true |
| underbelly outline | v1 | final_locked | true |
| underbelly material | v2 | final_locked | true |
| underbelly palette QA | v2 | final_locked | true |
| front_flipper_near | current locked lineage | final_locked | true |
| front_flipper_far geometry | FINAL_v4 | final_locked | true |
| front_flipper_far material/palette runtime | v1 | final_locked | true |

## Inactive / historical
- Underbelly Pattern/Detail v1: `superseded`, active=false.
- Swim Pose v1 package: `qa_candidate`, active=false until explicit user approval.
- Historical Underbelly FINAL packages predating FINAL_v4: `archived`, active=false.
- Historical body_with_rear FINAL packages predating Geometry FINAL_v2: `archived`, active=false.

## Migration rules
- Historical manifests are not rewritten only to normalize vocabulary.
- This Registry is the additive normalized index.
- User approval is required before any `final_locked` promotion.
- Exactly one active lineage is allowed per scope.
- Locked source binaries are never overwritten by lifecycle management.
- GitHub main determines production lineage; Notion records decisions/specification; Drive stores binary/QA/package artifacts.
