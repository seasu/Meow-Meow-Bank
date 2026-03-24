---
name: flutter-tinder-uiux
description: >
  Professional Flutter UI/UX designer skill inspired by Tinder's design system.
  Use for swipe cards, profile/match/chat flows, onboarding, and polished motion-heavy mobile UI.
---

# Flutter Tinder-Style UI/UX Designer

## Design Philosophy

1. Gesture-first interaction（Swipe 為核心）
2. 視覺層級（大圖、清楚主次）
3. 大膽色彩與漸層系統
4. 粗體且可讀性高的字體
5. 有目的的動畫與微互動
6. Card-based layout（圓角、陰影、堆疊）

## Architecture Pattern

```text
lib/
├── main.dart
├── app.dart
├── core/theme/
│   ├── app_theme.dart
│   ├── app_colors.dart
│   ├── app_typography.dart
│   └── app_spacing.dart
├── core/utils/
├── features/
│   ├── onboarding/
│   ├── swipe/
│   ├── profile/
│   ├── matches/
│   └── chat/
├── shared/widgets/
└── router/app_router.dart
```

## Theme System

- 定義 `AppColors`（含 Tinder 風格 primary gradient）
- 定義 `AppTypography`
- 定義 `AppSpacing`（包含 card radius / button radius / shadows）

## Core Component Patterns

- Swipe Card Stack
- Action Button Row
- Profile Screen
- Match Overlay
- Chat Screen
- Bottom Navigation
- Onboarding Flow

詳細程式碼請看 `references/components.md`。

## Animation Recipes

- Spring back card
- Pulse effect（Match）
- Staggered list entry

詳細請看 `references/animations.md`。

## Recommended Packages

`flutter_card_swiper`, `go_router`, `flutter_riverpod`, `flutter_animate`, `cached_network_image`, `confetti`, `shimmer`, `google_fonts`.

## Screen Checklist

- 使用設計 tokens（無 magic number）
- loading/empty/error state 完整
- 支援深色模式與可及性
- 動畫可達 60fps

## How to Use

1. 先確認使用者要做哪個畫面/流程
2. 先描述版面與互動，再下 code
3. 以 theme system 統一風格
4. 每個畫面至少一個有意義動畫
5. 交付完整可執行檔案
