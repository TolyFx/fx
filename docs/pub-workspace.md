<!-- 本文说明 FrameworkX Pub Workspace 的成员边界、依赖约束、维护命令和发布前检查。 -->

# Pub Workspace 维护指南

## 目标与边界

本仓库使用根 `pubspec.yaml` 作为唯一 Workspace 入口，统一解析根 Flutter 应用、CLI、接口包和 `modules` 下的真实插件包。

以下内容不属于 Workspace：

- `cli/modules_template`：包含模板变量，不是真实可解析包。
- `cli/modules_template/example`：仅用于模板示例。
- 各插件自己的 example：保持示例职责，不参与根级发布编排。

Workspace 负责本地包发现和统一依赖解析，不负责版本升级、CHANGELOG、Git 标签或批量发布。

## 统一解析

所有依赖操作从仓库根目录执行：

```bash
flutter pub get
dart pub workspace list
```

仓库只维护根级 `pubspec.lock` 和 `.dart_tool`。成员目录不得提交独立 lockfile 或 package config。

## 内部依赖

成员之间必须声明正常的 hosted 版本约束：

```yaml
dependencies:
  fx_event: ^0.0.1
  fx_mod: ^0.1.0
```

不要声明相对路径：

```yaml
dependencies:
  fx_event:
    path: ../../core/fx_event
```

在 Workspace 内，只要本地包版本满足约束，Pub 会自动使用本地源码；包被独立使用或发布后，Pub 会按同一约束从 hosted 源获取依赖。

修改内部包版本时，必须同步检查所有依赖它的成员约束。精确版本包含 build 后缀时，依赖也必须覆盖完整版本，例如 `0.0.1+4`。

## SDK 与开发依赖

Workspace 成员的 Dart SDK 下限不得低于 3.6：

```yaml
environment:
  sdk: '>=3.6.0 <4.0.0'

resolution: workspace
```

所有成员共享一套版本解析。开发依赖也必须存在交集，本仓库统一使用：

```yaml
dev_dependencies:
  flutter_lints: ^5.0.0
```

新增或升级依赖后必须在根目录重新执行 `flutter pub get`，以便尽早发现成员间的版本冲突。

## 新增成员

新增真实插件包时：

1. 在根 `pubspec.yaml` 的 `workspace` 列表中加入包路径。
2. 将包的 Dart SDK 下限设为 3.6 或更高。
3. 在包的 `pubspec.yaml` 中增加 `resolution: workspace`。
4. 内部依赖使用 hosted 版本约束，不使用相对 `path`。
5. 在根目录执行 `flutter pub get` 和 `dart pub workspace list`。
6. 运行新包测试与依赖它的上层包测试。

模板、生成样板和 example 不应误加入 Workspace。

## 分析与测试

全仓静态分析：

```bash
flutter analyze
```

测试单个成员：

```bash
cd modules/core/fx_event
flutter test
```

内部依赖发生变化时，应按依赖方向验证。例如：

```text
fx_media → fx_media_picker
fx_event + fx_mod → fx_mod_flutter
```

修改底层包后至少测试它本身和直接依赖它的上层包。

## 发布预检

在根目录指定目标成员执行：

```bash
dart pub -C modules/core/fx_event publish --dry-run
```

可发布包必须具备自己的 `LICENSE`、`README.md` 和 `CHANGELOG.md`，且不得依赖 Workspace 外的相对路径。

发布标签采用包名隔离：

```text
fx_event-v0.0.2
fx_mod-v0.1.1
fx_mod_flutter-v0.1.1
```

存在内部依赖时先发布底层包，确认 hosted 源能够解析新版本后，再发布上层包。

## 标签自动发布

仓库通过 `.github/workflows/publish-package.yml` 统一发布公开的 `fx_*` 包。标签格式为：

```text
包名-v版本
```

例如发布 `fx_ability 0.1.1`：

```bash
git tag fx_ability-v0.1.1
git push origin fx_ability-v0.1.1
```

工作流会校验 Workspace 成员、标签版本、`pubspec.yaml` 版本和 `publish_to`，随后执行目标包测试、发布预检和正式发布。GitHub 仓库必须配置 `PUB_CREDENTIALS_B64` Secret；该 Secret 保存经过 Base64 编码的 pub.dev OAuth 凭证，只允许发布维护者管理。

## 当前注意事项

- `fx_install_plugin` 加入 Workspace 后，Dart SDK 下限由 2.12 提高到 3.6。
- 部分包的本地版本落后于 pub.dev，发布前必须先核对线上版本，禁止版本倒退。
- 根应用、成员包和包模板统一采用 GPL-3.0；包含第三方来源代码的成员还必须保留对应的第三方版权与许可声明。
- `toly_menu` 与 `toly_menu_manager` 已被上游标记为 discontinued，应安排独立迁移。
- macOS 依赖中的 `window_manager` 与 `screen_retriever_macos` 尚未支持 Swift Package Manager，后续 Flutter 版本可能提升为错误。
