# Sea Turtle v3 · Underbelly Outline v1

- Status: **Source-pixel Outline Ownership Locked**
- Runtime seam visibility: **Pending whole-shape seam QA**
- Approval date: **2026-10-01**
- Authoritative Master: **Q3 Canonical Master**
- Source geometry: **Underbelly FINAL_v4**
- Canvas: **2048×2048 RGBA**
- ImageGen: **not used**
- Method: approved clean-contour Ownership Overlay v2 → deterministic Mask / Asset / Removed Remainder / Recomposite

## QA
- Outline ownership: **17,245 px**
- Outside Underbelly: **0 px**
- Asset↔Mask mismatch: **0 px**
- Asset↔Remainder overlap: **0 px**
- Source gap: **0 px**
- Transparent RGB residue: **0 px**
- Recomposite changed pixels: **0**
- Recomposite max channel diff: **0**

## Outline Attachment / Seam Rule
- `Source Material Outline` and `Runtime Visible Outline` are separate concepts.
- The source-pixel decomposition may own outline pixels at a Part boundary for exact source reconstruction.
- At runtime, only the **exterior silhouette** should read as a strong continuous outline.
- Boundaries where two Parts attach (Body↔Belly, Belly↔Shell, Flipper Root↔Body/Belly, etc.) must not show two independent strong outlines.
- Attachment/internal seams use one of: **single-owner boundary**, **suppressed outline**, or **soft structural shadow/seam**.
- Locked Geometry/Ownership is not redrawn to solve runtime seam appearance. The compositor/runtime outline role handles visibility.
- Whole-shape recomposition/runtime QA must explicitly check double-line, seam thickness, disconnected-piece appearance, and palette/material consistency across the attachment.

## Drive
- Folder: https://drive.google.com/drive/folders/1x7CKdzsM-aktmPwVul0iz9LHZYhENfqc
- Package: https://drive.google.com/file/d/1_3pHbLU5oBp_-2tBfaw6nP5xRdxo8ECZ/view?usp=drivesdk
- Overlay: https://drive.google.com/file/d/1NUxDzwH_ULA6sZdZshcj6MW8lvbr6Izr/view?usp=drivesdk
- Asset: https://drive.google.com/file/d/1e_TjjKEdjbPzecUUFLqTlHlxgzHbXIFV/view?usp=drivesdk
- Mask: https://drive.google.com/file/d/1CB1B1DbAqIleTGupZlABD0Cq_c2ZJ0hG/view?usp=drivesdk
- Removed Remainder: https://drive.google.com/file/d/1MPbUl9W2nzXQF2-qxS2XOFDLnNHSitVv/view?usp=drivesdk
- Recomposite: https://drive.google.com/file/d/1tQ7J7OwR9RBPvOccCjYsOthdesWn8Ilr/view?usp=drivesdk
- Diff: https://drive.google.com/file/d/1i3Ot9bi79ABthCJpIBcE9N5APirS-5el/view?usp=drivesdk

## Next Gate
**Underbelly Pattern / Detail Ownership Overlay**
