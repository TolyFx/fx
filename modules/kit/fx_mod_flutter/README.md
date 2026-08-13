# fx_mod_flutter

`fx_mod_flutter` 是 `fx_mod` 的 Flutter 适配层。模块自行声明国际化与
Widget 作用域，宿主只负责选择模块并读取聚合结果。

## 定义模块

```dart
final class SettingsModule extends FxAppModule {
  @override
  String get id => 'settings';

  @override
  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      <LocalizationsDelegate<dynamic>>[
        SettingsLocalizations.delegate,
      ];

  @override
  Iterable<Locale> get supportedLocales =>
      SettingsLocalizations.supportedLocales;

  @override
  Iterable<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: '/settings',
          builder: buildSettingsPage,
        ),
      ];

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SettingsScope(child: child);
  }
}
```

## 宿主拼装

```dart
final FxFlutterModRuntime modules = FxFlutterModRuntime(
  <FxAppModule>[
    CoreModule(),
    SettingsModule(),
  ],
);

await modules.start();

MaterialApp.router(
  localizationsDelegates: modules.localizationsDelegates,
  supportedLocales: modules.supportedLocales,
  builder: (BuildContext context, Widget? child) {
    return modules.wrap(context, child ?? const SizedBox.shrink());
  },
);
```

也可以直接让适配层创建路由器，宿主仍可传入全局守卫和错误页：

```dart
final GoRouter router = modules.createRouter(
  navigatorKey: rootNavigatorKey,
  redirect: appRedirect,
  errorBuilder: buildNotFoundPage,
);
```

## 聚合规则

- 模块先按 `fx_mod` 依赖图进行稳定拓扑排序。
- Delegate 按模块依赖顺序聚合，同一运行时类型只保留第一个。
- Locale 取所有模块声明的并集，并保持首次声明顺序。
- Widget 作用域中依赖模块位于外层，消费模块位于内层。
- Flutter 自带 Delegate 也应由基础应用模块声明，宿主无需另行硬编码。

## 路由规则

- `rootRoutes` 直接进入根 Navigator，适合启动和登录等全屏页面。
- `routes` 自动进入模块独占的 `ShellRoute + Navigator`。
- `wrapRoutes` 只包装模块局部 Navigator，适合模块页面状态作用域。
- 顶层路径必须以 `/` 开头，并在所有模块中保持唯一。
- GoRoute 的 `name` 在所有模块和子路由中保持唯一。
- 整个应用最多只能有一个模块声明 `initialLocation`。
