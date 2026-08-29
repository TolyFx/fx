# fx_account

可复用的账户安全界面包。包内负责页面布局、交互状态和中英文文案；宿主通过回调接入认证、网络请求、提示与导航。

## 接入本地化

```dart
MaterialApp(
  localizationsDelegates: const [
    ...FxAccountLocalizations.localizationsDelegates,
  ],
  supportedLocales: FxAccountLocalizations.supportedLocales,
)
```

如果宿主已经注册 Flutter 自带的本地化代理，也可以只追加
`FxAccountLocalizations.delegate`，并将包支持的语言合并进宿主的
`supportedLocales`。

## 修改密码

```dart
ChangePasswordPage(
  onSubmit: (oldPassword, newPassword) async {
    await accountService.changePassword(oldPassword, newPassword);
  },
)
```

## 注销账户

```dart
DeleteAccountPage(
  onSubmit: (password) async {
    await accountService.deleteAccount(password);
  },
  onMessage: showToast,
)
```
