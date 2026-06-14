---
name: "fx-boot-starter-usage"
description: "使用 fx_boot_starter 接入 App 启动流程。适用于需要闪屏页、初始化异步任务、启动状态管理的场景。"
metadata:
  author: toly
  version: "0.2.0"
  tags: [fx, boot, starter, splash, init, flutter, app]
---

# fx_boot_starter 使用指南

## 适用版本

fx_boot_starter: 0.2.0

## 环境检测

检查项目是否包含 fx_boot_starter 依赖。
- 没有 → 添加依赖
- 有但版本不同 → 提示用户升级

---

## 核心概念

| 概念 | 说明 |
|------|------|
| AppStartRepository\<S\> | 启动数据仓库，实现 `initApp()` 返回配置 |
| AppStartAction\<S\> | 生命周期回调（onLoaded/onStartSuccess/onStartError） |
| FxStarter\<T\> | 应用入口 mixin，组合 Repository + Action + 全局异常捕获 |
| AppStartScope\<S\> | Widget tree 注入，提供 AppStartBloc |
| AppStartListener\<S\> | 监听状态变化，触发 Action 回调 |
| AppStatus | sealed class（Starting/LoadDone/Success/Failed） |

---

## 使用流程

```
1. 定义配置类      → App 启动后需要的数据结构
2. 实现 Repository → initApp() 中执行初始化任务
3. 实现 Application → with FxStarter，实现回调
4. main 启动       → MyApplication().run()
5. UI 层监听       → AppStartListener 包裹闪屏页
```

---

## 代码模板

#[[file:references/boot_starter.md]]

---

## API 速查

| API | 作用 |
|-----|------|
| `MyApp().run()` | 启动应用（FxStarter mixin） |
| `AppStartScope.of<S>(context)` | 获取 AppStartBloc 实例 |
| `context.startApp<S>()` | 手动触发启动 |
| `AppStartScope(minStartDurationMs: 800)` | 自定义最小闪屏时间 |

---

## 生成指导

1. 配置类用 `const` 构造
2. Repository 的 `initApp()` 内自由组织初始化顺序
3. 无依赖的任务可用 `Future.wait` 并行
4. `onStartSuccess` 中做页面跳转
5. `onStartError` 中引导用户处理错误
6. `onGlobalError` 中上报未捕获异常
7. 显式声明所有类型
