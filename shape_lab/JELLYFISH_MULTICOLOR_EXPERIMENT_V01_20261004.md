# Jellyfish Multi-Color Experiment v0.1

Date: 2026-10-04  
Classification: **LABS / Palette Lab / Experimental**  
Route: `?lab=palette&experiment=jellyfish-multicolor`  
Status: **PoC / Candidate / Not Production**

## Purpose
Validate a static multi-color palette system on the selected Jellyfish R4 Compact master without changing geometry, alpha, motion, or the production color catalog.

## Separation rule
- Existing Drop 01 six production colors remain untouched.
- Aurora Sea Final / Locked / Active remains untouched.
- This experiment is not a product color and is not part of password identity.
- The selected Jellyfish Static Master remains the only geometry source.
- Weight maps and recolored previews are derived experiment artifacts only.
- No promotion to Production occurs without explicit user approval.

## Proposed render model
1. Lock Jellyfish Static Master.
2. Decompose color/light while preserving alpha and shape.
3. Create four soft semantic color weights:
   - Bell Upper
   - Bell Lower / Scallop
   - Main Tentacles
   - Rear / Sub Tentacles
4. Apply palette slots through overlapping weight maps.
5. Reapply fixed shading/highlight/edge finish.
6. Run 2048 / 512 / 128 / 58 px QA.
7. If successful, evaluate promotion into a future unified Color System.

## Initial PoC palette set
- Original
- Ocean Dream
- Coral Dawn
- Moon Jelly

## Gate state
Current gate: **classification + LABS isolation complete**.  
Next gate: **Jellyfish Static Master canonicalization and lock**.  
Multi-Color implementation resumes only after Static Master lock.
