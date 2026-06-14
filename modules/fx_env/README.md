# fx_env

极轻量的 Flutter 平台检测工具包，提供统一的 OS 枚举和便捷的平台判断属性。

## 安装

```yaml
dependencies:
  fx_env: ^0.0.1
```

## 使用

```dart
import 'package:fx_env/fx_env.dart';

// 直接使用全局实例
if (kApp.isMobile) {
  // 移动端逻辑
}

if (kApp.isDesktop) {
  // 桌面端逻辑
}

// 获取当前 OS 枚举
print(kApp.os); // OS.windows / OS.android / ...
```

## API

| 属性 | 说明 |
|------|------|
| `kApp.os` | 当前平台枚举值 |
| `kApp.isAndroid` | Android |
| `kApp.isIos` | iOS |
| `kApp.isOhos` | 鸿蒙 HarmonyOS |
| `kApp.isWindows` | Windows |
| `kApp.isMacOS` | macOS |
| `kApp.isLinux` | Linux |
| `kApp.isWeb` | Web |
| `kApp.isDesktop` | macOS / Windows / Linux |
| `kApp.isMobile` | Android / iOS / OHOS |
| `kApp.isDesktopUI` | Desktop + Web（大屏 UI 布局判断） |

## 鸿蒙支持

Flutter SDK 目前无法识别鸿蒙平台，通过编译时参数注入：

```bash
flutter build apk --dart-define=FX_OS=ohos
```

注入后 `kApp.isOhos` 为 `true`，`kApp.isMobile` 为 `true`。

## OS 枚举

```dart
enum OS {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
  ohos,
  unknown,
}
```
