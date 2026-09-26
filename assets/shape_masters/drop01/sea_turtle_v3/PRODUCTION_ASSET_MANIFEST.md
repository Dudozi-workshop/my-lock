# Sea Turtle v3 Production Asset Manifest

Updated: 2026-09-26

## Source policy
- Approved master shape reference remains locked.
- v2 runtime PNGs are not production source.
- v3 production assets are derived from the approved transparent master only.

## Google Drive production folder
- Folder: v3 Canonical Production
- Folder ID: 1S49_Sq_Bek4LS2GcZ3QxdJrZLTHAG60u

## Current production assets

### Canonical Master
- File: `sea_turtle_master_v3_2048.png`
- Drive ID: `1x4-U3ihSzfjdRKbBhFzkqPt-7sZsrI3y`
- SHA-256: `7b8013dadc9068df09bc10e6515ab50779b1e190538bc27752a4284bcf602251`
- Status: COMPLETE

### Master Alpha
- File: `master_alpha_2048.png`
- Drive ID: `1Orjy_f2-G9rjaJRxsR5pgFy4HGxCIxjQ`
- SHA-256: `61d0654d66543afb857279487b88fb607f840dc4bab2e65473fee831f294d042`
- Status: COMPLETE

### Shell Mask
- File: `shell_mask_2048.png`
- Drive ID: `1WOiqp2riXMtpcPWB3T1wV5qz4wtg915m`
- SHA-256: `b9af6b1fd8d9454bc1837b64ffafd4fad66925a5064a5f7a122c7902289ce38f`
- Status: DRAFT QA COMPLETE / semantic refinement may continue

### Belly Mask
- File: `belly_mask_2048.png`
- Previous Drive ID: `12FysUfX-i4qdGU9E4KftGbDcWMjteTek`
- Previous SHA-256: `fb3fa0c869c194edeffa1992edc360dba3895f04186b7e05810e11f4c832e118`
- Status: **REWORK REQUIRED — visible-only mask invalid**
- Requirement: continuous hidden underlap behind Near/Far front flippers; replacement must pass Reveal QA before registration

## Next
1. Correct Belly hidden-underlap mask
2. Belly Reveal QA/QC
3. Shell detail mask
4. Static / Near / Far F0 split
5. Geometry ownership / overlap / gap QA
6. Material decomposition
7. Basic recomposition QA
8. Aurora Sea dynamic-material PoC
9. Runtime compositor
10. Static Master Lock
