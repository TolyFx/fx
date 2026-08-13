# fx_mod

`fx_mod` 是一个纯 Dart 的模块拼装与生命周期内核。它从应用模块化实践中提炼，
不绑定 Flutter、路由框架、状态管理或服务定位器。

## 核心边界

- `FxModule` 密封模块身份、依赖、贡献和生命周期。
- `FxModRuntime` 校验依赖图，按拓扑顺序启动、按逆序释放。
- `FxModContext` 由宿主显式提供跨模块共享能力。
- `FxModContribution` 允许 Flutter、GoRouter 等适配层声明自己的贡献类型。
- `FxModEvent` 用于宿主广播认证、前后台等一对多生命周期事件。
- `FxModException` 接入 `fx_exception`，统一携带错误码、根因和堆栈。

## 快速开始

```dart
class DatabaseModule extends FxModule {
  @override
  String get id => 'database';

  @override
  Future<void> onPrepare(FxModContext context) async {
    final Database database = await openDatabase();
    context.provide<Database>(database);
  }

  @override
  Future<void> onDispose(FxModContext context) {
    return context.read<Database>().close();
  }
}

class SyncModule extends FxModule {
  @override
  String get id => 'sync';

  @override
  Set<String> get dependencies => const <String>{'database'};

  @override
  Future<void> onStart(FxModContext context) {
    return context.read<Database>().synchronize();
  }
}

final FxModRuntime runtime = FxModRuntime(<FxModule>[
  SyncModule(),
  DatabaseModule(),
]);

await runtime.start();
await runtime.dispose();
```

## 生命周期

```text
created
  -> preparing
  -> prepared
  -> starting
  -> running
  -> disposing
  -> disposed
```

准备或启动失败时，运行时进入 `failed`，并逆序释放所有已经完成准备的模块。

## 设计约束

- 模块列表在运行时创建时冻结，不支持运行期间动态安装。
- 依赖必须使用模块 ID 显式声明。
- 模块之间优先通过 `FxModContext` 中的稳定接口直接协作。
- 只有认证、应用生命周期等一对多通知才使用 `FxModEvent`。
- 路由、Provider、本地化属于上层适配，不进入核心包。
