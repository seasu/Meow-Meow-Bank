# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

Meow Meow Bank (喵喵金幣屋) — Children's financial literacy Flutter app (ages 4-10). Uses Provider for state management, SharedPreferences for persistence, Material 3 design with amber/gold color palette. All UI text is in Chinese.

### Key Commands

| Task | Command |
|------|---------|
| Get dependencies | `flutter pub get` |
| Analyze (lint) | `flutter analyze` |
| Unit tests | `flutter test` |
| Build web | `flutter build web` |
| Run web dev | `flutter run -d chrome` or `flutter run -d web-server --web-port=3000` |

### Architecture

- **Screens**: `home_screen.dart` (drag+form recording), `accessories_screen.dart` (collection/equip), `parent_screen.dart` (dashboard)
- **State**: `AppState` (ChangeNotifier) in `lib/providers/app_state.dart` — Provider pattern
- **Models**: `Transaction`, `Category`, `Wish` in `lib/models/transaction.dart`; `AccessoryDef`, constants in `lib/models/constants.dart`
- **Widgets**: `LuckyCat` (CustomPaint mascot), `BuildingScene` (level progression)
- **Utils**: `theme.dart` (AppColors + Material 3 theme), `sounds.dart` (AudioPlayer stub)

### Gotchas

- `flutter analyze` reports 2 pre-existing `ambiguous_import` errors in `app_state.dart` because Flutter's `foundation.dart` also exports a `Category` class. The app's `Category` is in `models/transaction.dart`.
- `main.dart` still has the default Flutter counter template and does not wire up Provider or the custom screens yet. New screens import Provider and `AppState` correctly.
- The `pubspec.yaml` requires Dart SDK `^3.11.0`; Flutter 3.41+ is needed.
- For headless web testing in CI/cloud, use `flutter run -d web-server --web-port=3000` (no Chrome window needed).
