# fx_ability

FrameworkX 的宿主能力抽象层，只定义接口契约，不提供平台或 UI 实现。

当前包含登录、媒体、权限、分享、存储、Toast 和上传能力。宿主应用负责实现所需接口；Toast 实现可注册到 `FxAbility` 全局入口。

## Toast 能力

实现 `Toastable`，即可向业务模块提供统一的 Toast 接口：

```dart
class AppToast extends Toastable {
  // 由宿主应用实现完整契约。
}
```

```dart
FxAbility().registerToast(AppToast());
FxAbility().toast.success('保存成功');
```

`FxAbility`、`Toastable`、`ToastAction` 和 `ToastType` 保持 `0.1.0` 的公开契约；`ToastAbility` 是兼容 fx 早期命名的类型别名。
