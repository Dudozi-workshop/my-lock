# Sea Turtle v3 · Underbelly Outline Mask v1

- Status: **Final / Locked / Active**
- Source Geometry: **Underbelly FINAL_v4_cleanup**
- Source Overlay: approved `underbelly_outline_ownership_overlay_candidate_v1_2048.png`
- Canvas: **2048×2048**
- Mask mode: **L binary / 0,255**
- ImageGen: **not used**
- Geometry changed: **0**

## Exact derivation
The mask was derived 1:1 from the approved Outline Ownership Overlay support. No expansion, shrink, or semantic reinterpretation was applied.

## QA
- Mask pixels: **8,647**
- bbox: **[442, 823, 1431, 1217]**
- Outside Underbelly source alpha: **0 px**
- Overlay↔Mask support mismatch: **0 px**
- Connected components: **1**
- Isolated 1 px noise: **0**
- PNG integrity: **PASS**

## Drive
- Mask: https://drive.google.com/file/d/1N2MtEjweXXC1QYaEbkslUzQWbKszHq66/view?usp=drivesdk
- Alignment QA: https://drive.google.com/file/d/1SmEHFr2xGGslfCpNxU1kCEb1N5AlmABL/view?usp=drivesdk
- Manifest: https://drive.google.com/file/d/107OSZSsC7j7PZiAeQ9K9rs8fvF6cAnnm/view?usp=drivesdk
- Package: https://drive.google.com/file/d/1tHJ1zB5CMo9UrgkM67O1-4chXh0AFIeW/view?usp=drivesdk

## Scope lock
`body_with_rear`, `shell_main`, `front_flipper_near`, `front_flipper_far`, and Underbelly Geometry remain unchanged.

## Next gate
**Outline Asset extraction** from the locked Underbelly FINAL_v4 source pixels using this Mask v1.
