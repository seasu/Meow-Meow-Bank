---
name: flutter-ci-guard
description: >
  Flutter 環境初始化與提交前品質把關 Skill。當環境中沒有 Flutter/Dart SDK、
  需要執行 dart analyze、修正第三方套件 API 錯誤、或設定 .gitignore 時觸發。
---

# Flutter CI Guard Skill

這個 Skill 記錄了在「無 Flutter SDK 的 Claude Code 環境」中開發 Flutter 專案的正確流程，以及從實際踩坑中學到的教訓。

## 1. 環境初始化（每個 Session 開始前確認）

### 確認 Flutter SDK 是否存在
```bash
/opt/flutter/bin/flutter --version
```

### 若不存在，安裝 Flutter SDK
```bash
wget -qO /tmp/flutter.tar.xz \
  https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.1-stable.tar.xz

tar -xf /tmp/flutter.tar.xz -C /opt/
git config --global --add safe.directory /opt/flutter
/opt/flutter/bin/flutter --version
```

### 安裝後必做
```bash
/opt/flutter/bin/flutter pub get
```

## 2. 提交前必跑 dart analyze

每次修改程式碼後、git commit 前，必須執行：

```bash
/opt/flutter/bin/dart analyze --fatal-infos
```

### Pre-commit Hook 設定
```bash
# .git/hooks/pre-commit
#!/bin/sh
DART=/opt/flutter/bin/dart
if ! command -v "$DART" > /dev/null 2>&1; then
  echo "⚠️ dart not found, skipping analyze"
  exit 0
fi

echo "▶ dart analyze --fatal-infos ..."
"$DART" analyze --fatal-infos
if [ $? -ne 0 ]; then
  echo "❌ dart analyze 發現問題，請修正後再 commit。"
  exit 1
fi
echo "✅ dart analyze 通過"
```

## 3. 修改第三方套件 API 前的流程

1. 先看 `pubspec.yaml` 的版本約束。
2. 查「該版本」API，而非最新版。
3. 修改前先確認型別（尤其 nullable）。

## 4. 新專案必備 .gitignore

包含 Flutter/Dart、Android、iOS、IDE、macOS 與 secrets 常見忽略項目；App 專案建議追蹤 `pubspec.lock`。

## 5. 棄用 API 修正：withOpacity → withValues

```dart
// 舊
color.withOpacity(0.5)

// 新
color.withValues(alpha: 0.5)
```

## 6. 本環境限制備忘

- Docker daemon：❌
- apt 安裝 dart：❌
- 直接下載 Flutter SDK：✅（安裝至 `/opt/flutter`）
