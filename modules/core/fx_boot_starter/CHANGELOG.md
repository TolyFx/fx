# Changelog

## 0.2.0

- Breaking: 移除 flutter_bloc 依赖，内部改为 StreamController + InheritedWidget
- Added: `AppStartScope.of<S>(context)` 获取 bloc 实例（替代 `context.read`）
- Added: `FxStarter.minStartDurationMs` getter 可覆盖
- Changed: 零第三方依赖

## 0.1.1

- Changed: 完善 README（设计理念、使用方式、API 表）
- Added: FxStarter mixin（runZonedGuarded + FlutterError.onError）

## 0.1.0

- Added: AppStartBloc 启动状态管理
- Added: AppStartScope / AppStartListener
- Added: AppStartRepository / AppStartAction 抽象
- Added: sealed class AppStatus（Starting/LoadDone/Success/Failed）
- Added: minStartDurationMs 最小启动时间保护
