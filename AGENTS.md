# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

Meow Meow Bank (喵喵金幣屋) — Children's financial literacy app (ages 4-10). Flutter 3.41, targeting Android + iOS + Web.

### Key Commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Run (Chrome) | `flutter run -d chrome` |
| Build web | `flutter build web --release` |
| Build APK | `flutter build apk --release` |

### Architecture

- **State**: `Provider` + `ChangeNotifier` (`lib/providers/app_state.dart`), persisted via `SharedPreferences`
- **Models**: `lib/models/` — `TxCategory`, `Transaction`, `Wish`, `AccessoryDef`, constants
- **Screens**: `lib/screens/` — Home (drag+form), Stats, DreamTree, Accessories, Parent
- **Widgets**: `lib/widgets/` — `LuckyCat` (CustomPainter), `BuildingScene`
- **Navigation**: Material 3 `NavigationBar` + `IndexedStack`

### Gotchas

- Flutter's `foundation.dart` exports a `Category` class — our model is named `TxCategory` to avoid collision.
- `audioplayers` requires platform-specific setup for iOS (add audio background mode to `Info.plist` if needed).
- Flutter SDK must be on PATH: `export PATH="/opt/flutter/bin:$PATH"`.
- GitHub Pages deploys Flutter web build with `--base-href "/Meow-Meow-Bank/"`.
