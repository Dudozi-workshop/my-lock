# MY LOCK

MY LOCK is a Flutter app for creating a customizable floating-shape lock experience across Android and iOS.

## Current MVP

- Bright white/lavender design system
- Bottom navigation: Customize / Shop / Lock Settings
- Large interactive LIVE PREVIEW
- Circle / triangle / square
- Pink / blue / yellow
- 9 floating objects
- Continuous motion and edge bouncing
- Tap hit testing
- POP particles + light haptic feedback
- Respawn about 0.18 seconds after a tap
- Low-density customization entry points: Background / Shape & Style / Effects
- Placeholder Shop and Lock Settings screens

## Product rules

- Customization is the primary product experience.
- Shape/color selection has no forced minimum.
- Password length: 3-6 tokens.
- Floating object count uses discrete presets instead of a slider.
- Real lock mode must guarantee the next two password tokens are present.
- Consecutive identical password tokens may appear as duplicate objects.

## Next targets

1. Connect shape/color selections to LIVE PREVIEW
2. Background, texture, and effect state
3. Password creation and validation
4. Next-two-token spawn guarantee
5. Persistent settings and secure password storage
6. Android/iOS native lock integration
7. Store ownership and in-app purchases

## Flutter

CI is pinned to Flutter 3.47.5 stable.

## Bootstrap

Android:

```bash
PLATFORMS=android bash tool/bootstrap.sh
flutter run
```

iOS/macOS:

```bash
PLATFORMS=ios bash tool/bootstrap.sh
flutter run
```

The bootstrap script generates missing native platform templates, restores the checked-in Dart source, runs `flutter pub get`, `flutter analyze`, and `flutter test`.

## CI

GitHub Actions validates:

- Ubuntu: Android bootstrap, analyze, test, debug APK build
- macOS: iOS bootstrap, analyze, test, no-codesign compile

This repository is the canonical private source for MY LOCK.


Repository initialized for independent MY LOCK development.
