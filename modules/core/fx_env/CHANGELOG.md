# Changelog

## 0.0.1+4

- Added: 补充单元测试覆盖所有 OS 分支
- Changed: README 重写为 fx_env 使用文档
- Changed: CHANGELOG 规范化格式
- Changed: pubspec homepage 填入仓库地址

## 0.0.1+3

- Changed: `isOhos` 通过 `--dart-define=FX_OS=ohos` 编译时注入识别，不再依赖 `OS.unknown`
- Changed: `kApp` 改为 `final`，防止意外重赋值
- Fixed: 移除 `os.dart` 中未使用的 import
- Added: 导出 `OS` 枚举和 `OSChecker`，外部可直接使用

## 0.0.1+2

- Added: `isMobile` 包含 ohos 平台

## 0.0.1

- Added: `AppEnv` 平台检测（Android/iOS/Windows/macOS/Linux/Web）
- Added: `OSChecker` 复合判断（isDesktop/isMobile/isDesktopUI）
- Added: `OS` 枚举，含 ohos 预留
- Added: 全局实例 `kApp`
