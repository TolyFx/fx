# Changelog

## 0.0.1+4

- 新增泛型 `FxException<C extends Code>`，作为模块异常的统一基类。
- `TraceMixin` 分发时隔离单个监听器异常，并允许子类重写监听器错误处理。
- 将请求异常实现迁入独立的 request 领域目录。
- 移除默认日志处理器和 Flutter 运行时依赖，保持协议层纯 Dart。

## 0.0.1

0.0.1+1 初始版本
0.0.1+2 完善 README
