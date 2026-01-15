# fx_boot_starter

一个轻量级的 Flutter 应用启动管理框架。

## 设计理念

**框架提供机制，不提供策略。**

- **单一入口** - 只有一个 `initApp()` 方法，使用者自由组织初始化逻辑
- **职责分离** - Repository 负责数据加载，Action 负责生命周期响应
- **类型安全** - 使用 `sealed class` 保证状态穷举，泛型支持自定义配置类型
- **最小侵入** - 通过 mixin 组合，不强制继承

### 为什么不分阶段？

很多启动框架会拆分成 `initEssential` → `initServices` → `loadConfig` 多个阶段。

我们选择单一 `initApp()` 的原因：

1. **大多数初始化有依赖关系**，无法真正并行
2. **Flutter 启动本身很快**，分阶段进度条意义不大
3. **细粒度错误上报是业务层职责**，使用者在 `initApp` 内自行处理
4. **保持简单**，减少概念和接口数量

```dart
// 使用者自己决定如何组织
Future<AppConfig> initApp() async {
  try {
    await initSp();
  } catch (e, s) {
    ErrorReporter.report('sp_init_failed', e, s);
    rethrow;
  }
  
  // 无依赖的任务可以并行
  await Future.wait([initDb(), fetchRemoteConfig()]);
  
  return AppConfig();
}
```

## 核心概念

### 启动状态流

```
AppStarting → AppLoadDone → AppStartSuccess
                  ↓
            AppStartFailed
```

- `AppStarting` - 启动中
- `AppLoadDone` - 加载完成，携带耗时和数据
- `AppStartSuccess` - 启动成功，可跳转主页
- `AppStartFailed` - 启动失败，携带错误信息

### 最小启动时间

框架保证闪屏至少展示 `minStartDurationMs`（默认 600ms），避免闪烁：

```dart
AppStartScope<AppConfig>(
  repository: repository,
  appStartAction: action,
  minStartDurationMs: 800,  // 自定义最小时间
  child: app,
)
```

## 使用方式

### 1. 定义配置类

```dart
class AppConfig {
  final String theme;
  final bool isFirstLaunch;
  
  const AppConfig({this.theme = 'light', this.isFirstLaunch = false});
}
```

### 2. 实现 Repository

```dart
class MyStartRepository implements AppStartRepository<AppConfig> {
  const MyStartRepository();

  @override
  Future<AppConfig> initApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 初始化存储
    await SpStorage.instance.init();
    
    // 初始化数据库
    await DatabaseHelper.init();
    
    // 加载配置
    final config = await loadUserConfig();
    
    return config;
  }
}
```

### 3. 实现 Application

```dart
class MyApplication with FxStarter<AppConfig> {
  const MyApplication();

  @override
  Widget get app => MyApp();

  @override
  AppStartRepository<AppConfig> get repository => const MyStartRepository();

  @override
  void onLoaded(BuildContext context, int cost, AppConfig state) {
    debugPrint("启动耗时: $cost ms");
  }

  @override
  void onStartSuccess(BuildContext context, AppConfig state) {
    context.go('/home');
  }

  @override
  void onStartError(BuildContext context, Object error, StackTrace trace) {
    context.go('/error', extra: error);
  }

  @override
  void onGlobalError(Object error, StackTrace stack) {
    // 上报未捕获异常
    CrashReporter.report(error, stack);
  }
}
```

### 4. 启动应用

```dart
void main(List<String> args) {
  MyApplication().run(args);
}
```

### 5. 监听启动状态（可选）

在 App Widget 中使用 `AppStartListener` 响应状态变化：

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppStartListener<AppConfig>(
        child: BlocBuilder<AppStartBloc<AppConfig>, AppStatus>(
          builder: (context, state) {
            return switch (state) {
              AppStarting() => SplashPage(),
              AppLoadDone() => SplashPage(),
              AppStartSuccess() => HomePage(),
              AppStartFailed(:final error) => ErrorPage(error: error),
            };
          },
        ),
      ),
    );
  }
}
```

## API 参考

### FxStarter<T>

| 成员 | 类型 | 说明 |
|------|------|------|
| `app` | `Widget` | 应用根 Widget |
| `repository` | `AppStartRepository<T>` | 启动数据仓库 |
| `onLoaded` | `void Function(context, cost, state)` | 加载完成回调 |
| `onStartSuccess` | `void Function(context, state)` | 启动成功回调 |
| `onStartError` | `void Function(context, error, trace)` | 启动失败回调 |
| `onGlobalError` | `void Function(error, stack)` | 全局异常回调 |

### AppStartRepository<T>

| 方法 | 说明 |
|------|------|
| `Future<T> initApp()` | 执行所有初始化任务，返回配置对象 |

## License

MIT
