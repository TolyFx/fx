# Fx 架构演进：一次类型统一的手术

> 2026-06-14 | 涉及模块: fx_exception, fx_dio, fx_trace, fx_event, fx_env

---

## 手术前的 X 光片

故事从一个简单的发现开始：fx_exception 和 fx_trace 都 export 了 `Trace`、`Code`、`TraceMixin`，但彼此不认识。

这意味着什么？如果一个 App 同时用了 fx_dio（依赖 fx_exception）和 fx_trace，它的网络层抛出的 `RequestException` 无法被 fx_trace 的 `FxTrace().addTraceListener(...)` 捕获。两套追踪系统在同一个 App 里各跑各的。

这不是 bug。App 能编译能运行。但使用者迟早会写出这样的代码然后困惑"为什么 listener 收不到网络异常"：

```dart
// 期望：统一监听所有异常
FxTrace().addTraceListener((Trace trace) {
  // fx_dio 的 RequestException 永远不会到这里
  // 因为它实现的是 fx_exception.Trace，不是 fx_trace.Trace
});
```

两个 `Trace` 的全限定名分别是 `package:fx_exception/src/trace.dart#Trace` 和 `package:fx_trace/src/trace/trace.dart#Trace`。Dart 的类型系统不会因为它们长得像就认为它们相同。

---

## 为什么会走到这一步

回溯历史，时间线是这样的：

**fx_trace 先存在。** 它从一开始就承担应用级追踪——`Trace` mixin、`Code` mixin、`TraceMixin` 分发器，加上 `LogTrace`/`TipTrace`/`CatchTrace` 和事件总线。它是第一个定义这些概念的包。

**fx_exception 是后来加的。** 当 fx_dio 做 0.0.5 重构时，需要一个轻量的异常协议层——只要 Trace/Code/TraceMixin 的最小定义，不要 fx_trace 的全家桶（日志级别、事件总线、State mixin）。于是从 fx_dio 内部拆出了 fx_exception。

问题出在拆的那一刻：fx_exception 定义了自己的 Trace/Code，没有复用 fx_trace 已有的定义。理由是合理的——fx_trace 的 Code 是 nullable 的（`int? get value`），而网络异常一定有 code，不应该 nullable。两者的语义需求确实不同。

但代价是：同一个框架里出现了两套不兼容的 Trace 体系。当用户同时使用 fx_dio 和 fx_trace 时，类型断裂就暴露了。

本质上这是"先有应用层，后有协议层"带来的问题。如果 fx_exception 先于 fx_trace 存在，fx_trace 自然会基于它来构建。但历史是反的。

---

## 约束空间

重构前先画清楚约束：

**硬约束：fx_exception 不能 breaking change。**

它已经发布到 pub.dev，fx_dio 依赖它，用户的项目依赖 fx_dio。如果改 fx_exception 的接口签名，整条依赖链都要联动升级。一个类型字段从 non-null 改 nullable，影响的不是一行代码，而是所有 `trace.code` 的调用点都要加 `?`。

**软约束：fx_trace 的 breaking change 可接受。**

它还在 0.0.x 阶段，pub.dev 语义上没有稳定性承诺，用户量小。

这两个约束决定了统一方向是单向的：fx_trace 适配 fx_exception，而非相反。

---

## 字段名之争：code vs value

fx_exception 的 `Code` mixin：

```dart
mixin Code {
  int get code;
}
```

fx_trace 的 `Code` mixin：

```dart
mixin Code {
  int? get value;
}
```

三个差异维度：

1. **命名**：`code` vs `value`
2. **nullable**：non-null vs nullable
3. **语义指向**：`Code.code` 是 tautology（"码的码"），`Code.value` 是"码的值"

如果这是一个全新设计，我会选 `value`——它更通用，没有语义重叠。但现实是 fx_exception 已发布，`code` 是既定事实。

最终方案不是选边，而是加一层：

```dart
mixin Code {
  int get code;
  int get value => code;  // 兼容别名
}
```

这个决策的代价是 Code mixin 多了一个永远不会被删除的 getter（删它就是 breaking）。但换来的是两边使用者代码零改动。在公共库的语境下，API 兼容性比代码美感重要。

---

## nullable 的深层矛盾

fx_exception 的 `Trace.code` 返回 `Code`（non-null）：

```dart
mixin Trace {
  Code get code;  // 每个异常必须有 code
}
```

这在网络层是对的——`RequestException` 的 code 一定是 `convert`/`emptyData`/`exception` 之一。

但 fx_trace 的 `LogTrace` 不需要 code。"页面加载完成"这条日志，它的 error code 是什么？没有。强制它有一个 code 是语义上的扭曲。

三条路：

1. fx_exception 的 Trace.code 改为 `Code?`——breaking，不可选
2. fx_trace 不实现 fx_exception 的 Trace——回到原点，类型不互通
3. fx_trace 的 LogTrace 给 code 一个默认值（0 = "无 code"）——语义妥协

我们选了方案 3。这是一个有意识的妥协：**类型系统上满足接口，业务语义上用约定值表示"不适用"**。

这和数据库设计中"用 -1 表示未知"是同一类取舍。完美主义者会觉得不优雅，但在"不能 breaking"的硬约束下，这是损失最小的路径。

使用者不会因为 `logTrace.code.value == 0` 而出 bug，因为没人会对日志的 code 做业务判断。

---

## with Code, Trace 的类型冲突

最初尝试让 fx_trace 的 Trace 实现类这样写：

```dart
class LogTrace with Code, Trace {
  @override
  final int code;  // 满足 Code.code
  // ...
}
```

报错：`'Trace.code' (Code Function()) isn't a valid override of 'Code.code' (int Function())`

原因：fx_exception 的 `Trace` mixin 声明了 `Code get code`（返回 Code 对象），而 `Code` mixin 声明了 `int get code`（返回 int）。当一个类同时 with 两者，两个 `code` getter 返回类型冲突。

看 fx_exception 里 `RequestException` 是怎么做的：

```dart
class RequestException with Trace {
  @override
  final RequestErrorCode code;  // RequestErrorCode with Code
}
```

它只 with 了 `Trace`，没有同时 with `Code`。`code` 字段返回的是一个实现了 `Code` 的枚举。

所以正确的模式是：具体类只 with `Trace`，`code` getter 返回一个 `Code` 对象：

```dart
class LogTrace with Trace {
  @override
  Code get code => _SimpleCode(0);
}

class _SimpleCode with Code {
  @override
  final int code;
  const _SimpleCode(this.code);
}
```

这比 `with Code, Trace` 多了一个内部类，但类型系统完全正确。没有 hack，没有 cast，没有 dynamic。

---

## 拆包的决策函数

fx_trace 里有追踪（Trace）和事件总线（Event）两套东西。拆不拆？

拆的成本：多一个包的维护（pubspec、changelog、版本号、发布流程）。
不拆的成本：包名承诺失效 + 使用者可能只需要事件总线却被迫引入 Trace 的所有依赖。

关键考量：**"只需要事件总线"的场景是否存在？**

答案是肯定的。一个纯粹的 UI 交互项目（比如工具类 App），可能需要跨页面发事件，但不需要异常追踪体系。如果为了用 `FxEmitter` 而引入 fx_exception 的传递依赖，这对使用者是不必要的负担。

验证拆分可行性：检查 emitter 目录的 3 个文件是否引用了 trace 相关代码。结果是零引用——它们从诞生起就是自包含的，只互相依赖。这说明当初放在一起就只是"顺手"，没有架构原因。

拆分后 fx_event 零第三方依赖（连 fx_exception 都不需要），这是最干净的状态。

---

## 去 stream_transform 的决策过程

fx_event 用 stream_transform 只为了一个方法：`Stream.whereType<E>()`。

Dart 的 `Iterable` 有 `whereType<T>()`，但 `Stream` 没有。这是 Dart SDK 的历史遗留不对称。stream_transform 填了这个空。

分析它的实现（`where.dart` + `from_handlers.dart`）：

1. `whereType<S>()` 调用 `transformByHandlers(onData: (event, sink) { if (event is S) sink.add(event); })`
2. `transformByHandlers` 创建一个 `StreamController<T>`，在 `onListen` 时才订阅源 stream

核心逻辑 5 行，但被包在一个通用抽象层里（支持自定义 onData/onError/onDone）。我们只需要 whereType 这一件事。

自行实现时的决策点：

**立即订阅 vs 延迟订阅？** stream_transform 在有人 listen 结果 stream 时才订阅源 stream（lazy）。如果我们立即订阅，对于 broadcast stream 的事件总线场景没有区别（因为调用 `whereType` 后紧接着就 listen）。但对于非 broadcast stream 或者"创建了 typed stream 但没有立即 listen"的场景，立即订阅会导致事件丢失。

作为一个公开的 extension（`WhereTypeStream`），行为应该对齐标准实现。所以选延迟订阅。

**为什么不直接 `stream.where((e) => e is E).cast<E>()`？** 功能上等价，但有两层中间 stream。对于高频事件（虽然事件总线通常不高频），每一层 stream 都是一次额外的微任务调度。单层 controller 是最小开销。

最终 25 行代码，替代了一个 20+ 方法的依赖包。对于公开类库，每个依赖都是对使用者的传递成本。

---

## 事件总线不做防抖——管道的职责边界

讨论过"用户快速点击发出两个事件"的场景。

如果事件总线做了防抖，会发生什么？一个定时刷新的场景（每秒发一次 `RefreshEvent`）会被总线层莫名其妙地丢掉事件。总线不知道哪些事件该抖、哪些不该抖——这个知识属于业务层。

类比：TCP 不会因为你发得太快就丢包（那是流控的事）；消息队列不会因为消息重复就去重（那是消费者的事）。管道的职责是忠实传递，策略交给端点。

`AsyncFxEvent` 天然有一定的"防重"效果：同一个实例只能 complete 一次。但这不是防抖，这是 Completer 的一次性语义——和"管道不做策略"并不矛盾。

---

## 全局单例的生命周期：什么时候该"懒"

评审 fx_dio 时讨论了 `FxDio` 单例是否需要 `dispose()`/`reset()` 来关闭 Dio 实例。

结论是不需要。但 `unregister` 时顺手 close 是合理的。

区分两种场景：
- **App 退出**：进程结束，OS 回收所有资源。单例 dispose 是多此一举。
- **主动注销**：`unregister(host)` 明确表示"这个 Host 我不用了"。此时不 close 的话，idle connection 会占用 fd，虽然影响极小，但语义上"不用了就关掉"更清晰。

一行代码的改动：`_hostMap.remove(host)` → `_hostMap.remove(host)?.dio.close()`。

这个决策的思考模型：**资源释放应该跟随"意图"，而不是跟随"生命周期终点"。** 单例没有终点，所以不需要全量释放。但 unregister 表达了明确意图。

---

## fx_env：当 SDK 不支持你的平台

fx_env 的核心问题不是架构问题，而是一个现实约束：**Flutter SDK 无法识别鸿蒙。**

`Platform.isAndroid`、`Platform.isIOS`... Dart 的 `Platform` 类没有 `isOhos`。当 App 运行在鸿蒙设备上时，所有平台检测都返回 false，最终落入 `OS.unknown`。

原始实现用了一个 hack：

```dart
bool get isOhos => _os == OS.unknown;
```

逻辑是"如果不是已知的任何平台，那就是鸿蒙"。这在今天碰巧能工作，但它的假设很脆弱——如果未来出现另一个 Flutter 不识别的平台（比如 Fuchsia 的某个阶段），它也会被误判为鸿蒙。

三种解决思路：

1. **运行时环境变量** `Platform.environment['FX_OS']`——不需要重新编译，但 Web 不支持 `Platform.environment`
2. **编译时 `--dart-define`**——零运行时成本，tree-shaking 友好
3. **构造参数注入**——测试友好，但使用者要手动传

选择方案 2，理由：

- 鸿蒙本身就是独立的构建通道（不同的引擎、不同的 toolchain），构建时就该确定平台身份
- `const String.fromEnvironment('FX_OS')` 是编译期常量，dead code elimination 可以把其他平台分支优化掉
- Web 不支持的问题不存在——Web 本身不需要跑鸿蒙 App

```dart
const String _fxOs = String.fromEnvironment('FX_OS');

OS _initOS() {
  if (_fxOs == 'ohos') return OS.ohos;
  if (kIsWeb) return OS.web;
  // ...
}
```

鸿蒙构建时：`flutter build apk --dart-define=FX_OS=ohos`。其他平台零感知。

这个决策的本质是：**当 SDK 层面的检测缺失时，用编译时注入填补空白，而不是用运行时猜测。** 猜测（`unknown == ohos`）迟早会猜错，注入（`--dart-define`）是确定性的。

---

## 收尾：架构的最终形态

```
fx_exception    协议层 — Trace/Code/TraceMixin 定义
    ↑
    ├── fx_dio     网络层 — RequestException 实现 Trace
    ├── fx_trace   追踪层 — FxTrace 单例 + LogTrace/TipTrace/CatchTrace
    │
fx_event        事件层 — FxEmitter + AsyncFxEvent（独立，零外部依赖）
fx_env          环境层 — OS 检测（独立，零外部依赖）
```

每个包的依赖数量：

| 包 | 运行时依赖 | 传递给使用者的 |
|---|---|---|
| fx_exception | 0 | 0 |
| fx_dio | dio + fx_exception | dio |
| fx_trace | fx_exception | fx_exception |
| fx_event | 0 | 0 |
| fx_env | 0 | 0 |

5 个包，最多的也只有 2 个运行时依赖。这是"最小依赖"原则的结果。

---

## 反思

这次重构最大的收获不是代码改动本身，而是明确了一个原则：

**公共库的首要约束不是技术完美性，而是 API 兼容性。**

在"Code 应该叫 code 还是 value"这个问题上，如果这是内部项目，我会直接重命名然后全局搜索替换。但因为是已发布的公共库，我们选择加别名。这不是最优雅的方案，但是最安全的方案。

好的架构不是没有妥协的架构——是妥协方向正确的架构。
