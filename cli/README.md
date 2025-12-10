# FX CLI

A Flutter module generator CLI tool.

## Installation

```bash
dart pub global activate --source path .
```

## Usage

### Create Command

创建一个 Flutter 模块，包含示例应用和自定义模板：

```bash
fx_cli create <module_name> -m [--platforms=android,ios]
```

**参数说明：**
- `<module_name>`: 模块名称（必需）
- `-m, --module`: 创建模块标志（必需）
- `--platforms`: 示例应用支持的平台（可选，默认：android,ios）

**示例：**
```bash
# 创建名为 my_widget 的模块（默认支持 Android 和 iOS）
fx_cli create my_widget -m

# 创建只支持 Android 的模块
fx_cli create my_widget -m --platforms=android

# 创建支持多个平台的模块
fx_cli create user_service -m --platforms=android,ios,web

# 创建支持所有平台的模块
fx_cli create full_app -m --platforms=android,ios,web,windows,macos,linux
```

**支持的平台：**
- `android` - Android 应用
- `ios` - iOS 应用
- `web` - Web 应用
- `windows` - Windows 桌面应用
- `macos` - macOS 桌面应用
- `linux` - Linux 桌面应用

**创建过程：**
1. 🚀 检查 Flutter 环境
2. 📦 创建 Flutter 包模块（使用 `flutter create --template=package`）
3. 🏗️ 创建示例应用（在模块内创建 example 目录，支持指定平台）
4. ⚙️ 配置示例应用依赖（自动添加对主模块的依赖）
5. 🎨 应用自定义模板（使用嵌入的模板文件）

**生成的目录结构：**
```
my_widget/
├── lib/
│   ├── src/
│   │   ├── bloc/
│   │   ├── repository/
│   │   └── view/
│   └── my_widget.dart
├── example/
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
├── test/
├── pubspec.yaml
└── README.md
```

**模板变量替换：**
- `{{MODULE_NAME}}` → 模块名称（如：my_widget）
- `{{MODULE_NAME_CAPITALIZED}}` → 首字母大写的模块名称（如：My_widget）

### Other Commands

```bash
# Validate template files
fx_cli validate

# Show version
fx_cli --version

# Show help
fx_cli --help
```

## Development

### Clear Cache and Reinstall

If you encounter version issues or cached problems:

```bash
# Clear cache and reinstall
rmdir /s /q .dart_tool
dart pub get
dart pub global deactivate fx_cli
dart pub global activate --source path .
```

### Direct Run (for testing)

```bash
# Run directly without global install
dart bin/cli.dart validate
dart bin/cli.dart create my_module -m
```
