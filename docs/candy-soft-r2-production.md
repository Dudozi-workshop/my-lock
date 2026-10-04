# Candy Soft R2 production integration — 2026-10-04

User approved the reviewed 3 default shapes × 3 default tones and requested MAIN/APK integration. Visual Master: Final / Locked / Active. Android physical-device QA remains pending.

Source review: 6209c329aadb89d5ab0e599bd485e28f1078da8e. Original atlas SHA256 and all six normalized image hashes remain in the immutable runtime manifest. No redrawing, ImageGen, or new website.

ShapeSpecRegistry initializes Candy assets before either main or lockMain starts. Shared ShapeSpecRenderer selects Candy by default for Soft Basic circle/triangle/square in pink/blue/yellow, so actual choice cards and Floating/lock painting share the approved result. Crayon, paid palette rendering, and locked H02B turtle rendering retain their established paths. Explicit useCandySoft=false retains the previous vectors for recovery.

Verification: review CI 91 tests passed; production PR builds/tests and release deployment evidence are recorded in GitHub Actions and Notion. Physical Android tests (LockActivity, relock, rotation, POP, repeated spawn, device performance) are not replaced by web or compilation checks.

This release commit carries [skip-apk-email] to produce/upload the authorized APK without sending an unrequested notification email.
