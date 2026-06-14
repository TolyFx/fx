# fx_dio

基于 Dio 的 Flutter HTTP 客户端封装，提供多 Host 管理、统一响应模型、认证拦截器、异常追踪和可扩展的分页解析。

## AI Skills

本包内置 AI 技能文件，支持 Kiro 等 AI IDE 自动生成代码：

| Skill | 说明 |
|-------|------|
| [fx-dio-usage](https://github.com/TolyFx/fx/tree/main/modules/fx_dio/skills/fx-dio-usage) | fx_dio 使用指南（Host 定义、Repository、注册、分页、异常、解密） |

激活 skill 后，AI 可按规范自动生成 Host、Repository、Model 等代码。

---

## 安装

```yaml
dependencies:
  fx_dio: ^0.0.5
```

## 快速开始

### 1. 定义 Host

```dart
enum AppEnv { dev, prod }

class MyHost extends RequestHost<AppEnv> {
  const MyHost();

  @override
  AppEnv get env => AppEnv.dev;

  @override
  Map<AppEnv, String> get value => {
    AppEnv.dev: 'dev.example.com',
    AppEnv.prod: 'api.example.com',
  };
}
```

### 2. 注册

```dart
FxDio().register(const MyHost());
```

### 3. 发起请求

```dart
final ApiRet<Map<String, dynamic>> ret = await const MyHost().get(
  '/users',
  convertor: (dynamic data) => data as Map<String, dynamic>,
);

if (ret.success) {
  print(ret.data);
}
```

---

## 特性

- **多 Host 管理** — 按类型注册，泛型查找
- **泛型环境枚举** — `RequestHost<E>` 由用户自定义环境
- **HostOptions** — 统一配置拦截器、分页解析器、日志开关
- **PaginateParser** — 按 Host 绑定自定义分页解析
- **运行时调整** — `rebase` 切域名、`setTimeout` 调超时、`setLog` 开关日志
- **异常追踪** — 基于 `fx_exception`，支持自定义业务异常 + 监听器
- **解密支持** — 整体解密或部分字段解密
- **日志拦截器** — debug 模式自动开启，耗时/参数/ANSI 颜色

---

## 依赖

| 包 | 说明 |
|----|------|
| [dio](https://pub.dev/packages/dio) | HTTP 客户端 |
| [fx_exception](https://pub.dev/packages/fx_exception) | 统一异常追踪协议 |
