---
name: "fx-dio-usage"
description: "使用 fx_dio 进行 Flutter HTTP 请求开发。基于实际项目实践的模式，包含 Host 定义、请求发起、返回值处理、异常追踪等核心流程。"
metadata:
  author: toly
  version: "0.0.5"
  tags: [fx, dio, http, flutter, network, request]
---

# fx_dio 使用指南

## 适用版本

fx_dio: 0.0.5 | fx_exception: 0.0.1+1

## 环境检测

检查项目是否包含 fx_dio 依赖。
- 没有 → 添加依赖
- 有但版本不同 → 提示用户升级技能或保持版本一致

---

## 开发流程

```
1. 定义 Host     → 服务地址 + 自定义环境枚举
2. 定义 Model    → 数据结构 + fromApi
3. 编写 Repository → 请求方法 + convertor
4. 注册 Host     → App 启动时配置 HostOptions
5. 调用          → 获取 ApiRet<T>
```

---

## 1. Host 定义

继承 `RequestHost<E>`，`E` 为自定义环境枚举。

#[[file:references/host.md]]

---

## 2. Repository

直接用 host 实例调用 get/post，convertor 负责数据转换。

#[[file:references/repository.md]]

---

## 3. 注册与配置

通过 `HostOptions` 一次性配置日志、分页解析器、拦截器。

#[[file:references/register.md]]

---

## 4. 自定义分页

不同后端的分页格式不同，按 Host 绑定 `PaginateParser`。

#[[file:references/paginate.md]]

---

## 5. 业务异常

后端统一格式 `{ code, message, data }` 时，convertor 中检测业务码抛出自定义异常。

#[[file:references/biz_exception.md]]

---

## 6. 解密

支持整体解密和部分字段解密。

#[[file:references/decrypt.md]]

---

## API 速查

| API | 作用 |
|-----|------|
| `FxDio().register(host, options: ...)` | 注册 Host |
| `FxDio().auth<T>(auth)` | 注册认证 |
| `FxDio().rebase<T>(host)` | 运行时切换域名 |
| `FxDio().setTimeout<T>(...)` | 动态调超时 |
| `FxDio().setLog<T>(bool)` | 动态开关日志 |
| `host.get / post / put / patch / delete` | HTTP 方法 |
| `ret.success` / `ret.failed` | 判断结果 |
| `ret.data` | 获取数据 |
| `ret.paginate?.total` | 分页总数 |
| `ret.msg` | 错误信息 |
| `(ret as ApiFail).trace.error` | 原始异常对象 |

---

## 生成指导

1. 占位符必须根据用户需求替换
2. Host 地址、端口从用户上下文推断
3. Model 字段从 API 响应中解析
4. convertor 适配实际返回格式
5. 显式声明所有类型（strict-raw-types）
6. 环境枚举由用户决定
