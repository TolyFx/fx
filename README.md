# fx

FrameworkX Flutter 应用与插件包合集。本仓库使用 Pub Workspace 统一维护根应用、CLI、接口包和各层插件包的依赖解析。

## Workspace 维护

在仓库根目录统一安装依赖：

```bash
flutter pub get
dart pub workspace list
```

成员包只声明可发布的 hosted 版本约束，Workspace 会在本地自动解析到仓库源码。不要为内部包添加相对 `path` 依赖，也不要提交成员包自己的 `pubspec.lock` 或 `.dart_tool`。

测试或校验单个包：

```bash
flutter test modules/core/fx_event
dart pub -C modules/core/fx_event publish --dry-run
```

成员边界、依赖规则和新增包步骤详见 [Pub Workspace 维护指南](docs/pub-workspace.md)。

## 许可证

仓库根应用、CLI、接口包、插件包与包模板统一采用 GNU General Public License v3.0。包含第三方来源代码的模块同时保留对应的第三方版权与许可声明。

## 创建模块

> flutter create --template=package fx_ability
