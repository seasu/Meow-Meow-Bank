---
name: flutter-dev
description: >
  Flutter app development skill for Claude Code. Use this skill whenever the user wants to create,
  modify, debug, or architect a Flutter/Dart application.
---

# Flutter Development Skill

## Quick Reference: Project Commands
```bash
flutter create --org com.example my_app
dart analyze
dart format .
flutter build apk --release
flutter build ios --release
flutter build web
```

## 1. Project Structure Convention

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── services/
├── features/
│   └── <feature>/
│       ├── models/
│       ├── repositories/
│       ├── providers/
│       ├── screens/
│       └── widgets/
├── shared/widgets/
└── l10n/
```

Rules: 一個 widget 一個檔案、snake_case 命名、`main.dart` 保持精簡。

## 2. State Management Guide

- 小型：`setState`
- 中型（預設推薦）：Riverpod
- 中型（既有團隊）：Provider
- 大型：Bloc/Cubit

## 3. Navigation

使用 `go_router` 宣告式路由（`MaterialApp.router`）。

## 4. Widget Best Practices

- Composition over inheritance
- `build()` 過長就拆 widget
- 優先 `const` constructors
- 非必要不使用 `StatefulWidget`

## 5. Theming & Styling

建立集中式 theme，避免硬編碼色彩，改由 `Theme.of(context)` token 取值。

## 6. Data Layer Pattern

- Model: `fromJson/toJson`
- Repository: 封裝資料來源
- 推薦套件：`dio`、`shared_preferences`、`hive/isar/drift`、`json_serializable`、`freezed`

## 7. Error Handling

以 `Result<Success/Failure>` 模式統一錯誤回傳。

## 8. Testing Essentials

- Unit tests
- Widget tests

## 9. Performance Checklist

- `const` widgets
- `ListView.builder`
- 降低重建範圍
- `flutter run --profile` + DevTools

## 10. Recommended pubspec starter

包含 `flutter_riverpod`、`go_router`、`dio`、`cached_network_image`、`intl` 等常用套件。

## 11. Mobile-First Claude Code Workflow

- 小步快跑
- 常跑 `dart analyze`
- 維護 TODO 清單
- 常 commit

## 12. Platform-specific Notes

- Android：`minSdkVersion >= 21`
- iOS：deployment target >= 13、必要時跑 `pod install`
- Web：注意 plugin 相容性
