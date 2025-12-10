# 参数化 API 生成器

## 概述

重构后的 fx_dio_gen 工具链现在支持完全参数化配置，可以轻松适配不同的模块，并通过 Dart 类之间的关联而非脚本执行来工作。

## 核心改进

### 1. **参数化配置** 📋
```dart
final config = ApiGeneratorConfig(
  moduleName: 'User',
  yamlPath: 'doc/dev/request/user_apis.yaml',
  outputDir: 'lib/src/repository/api',
  enumClassName: 'UserApi',        // 可选，默认: {moduleName}Api
  requestClassName: 'UserRequest', // 可选，默认: {moduleName}Request
);
```

### 2. **类关联架构** 🔗
```dart
// 不再通过脚本执行，而是直接类调用
final generator = ApiGenerator(config);
await generator.generateAll();
```

### 3. **模块化生成器** 🧩
- `RequestFileGenerator` - 生成 Markdown 文档
- `UrlEnumGenerator` - 生成 URL 枚举
- `RequestClassGenerator` - 生成请求类
- `TestGenerator` - 生成测试用例

## 使用方式

### 单模块生成
```dart
import 'package:fx_cli/src/fx_dio_gen/api_gen_all.dart';
import 'package:fx_cli/src/fx_dio_gen/api_generator_config.dart';

void main() async {
  final config = ApiGeneratorConfig(
    moduleName: 'Apply',
    yamlPath: 'doc/dev/request/apply_apis.yaml',
    outputDir: 'lib/src/repository/api',
  );
  
  final generator = ApiGenerator(config);
  await generator.generateAll();
}
```

### 批量生成
```dart
import 'package:fx_cli/src/fx_dio_gen/batch_generator.dart';

void main() async {
  final configs = [
    ApiGeneratorConfig(
      moduleName: 'Apply',
      yamlPath: 'doc/dev/request/apply_apis.yaml',
      outputDir: 'lib/src/repository/api',
    ),
    ApiGeneratorConfig(
      moduleName: 'User', 
      yamlPath: 'doc/dev/request/user_apis.yaml',
      outputDir: 'lib/src/repository/api',
    ),
  ];
  
  final batchGenerator = BatchApiGenerator(configs);
  await batchGenerator.generateAll();
}
```

### 分步执行
```dart
// 只生成枚举
final enumGenerator = UrlEnumGenerator(config);
await enumGenerator.generate();

// 只生成请求类
final requestGenerator = RequestClassGenerator(config);
await requestGenerator.generate();
```

## 配置选项

### ApiGeneratorConfig 参数

| 参数 | 类型 | 必需 | 说明 | 默认值 |
|------|------|------|------|--------|
| moduleName | String | ✅ | 模块名称 | - |
| yamlPath | String | ✅ | YAML 配置文件路径 | - |
| outputDir | String | ✅ | 输出目录 | - |
| enumClassName | String | ❌ | 枚举类名 | `{moduleName}Api` |
| requestClassName | String | ❌ | 请求类名 | `{moduleName}Request` |
| testClassName | String | ❌ | 测试类名 | `{moduleName}RequestTest` |

### 自动生成的路径

```dart
config.enumFilePath     // {outputDir}/{moduleName}_url.dart
config.requestFilePath  // {outputDir}/{moduleName}_request.dart  
config.testFilePath     // test/request/{moduleName}_request_test.dart
config.docsDir          // doc/dev/request/api/{moduleName}
```

## 生成的文件结构

```
project/
├── doc/dev/request/api/
│   ├── apply/           # Apply 模块文档
│   ├── user/            # User 模块文档
│   └── order/           # Order 模块文档
├── lib/src/repository/api/
│   ├── apply_url.dart   # Apply 枚举
│   ├── apply_request.dart
│   ├── user_url.dart    # User 枚举
│   ├── user_request.dart
│   ├── order_url.dart   # Order 枚举
│   └── order_request.dart
└── test/request/
    ├── apply_request_test.dart
    ├── user_request_test.dart
    └── order_request_test.dart
```

## 优势

### 1. **灵活性** 🎯
- 支持任意数量的模块
- 每个模块独立配置
- 自定义类名和路径

### 2. **可维护性** 🔧
- 类型安全的配置
- 清晰的依赖关系
- 易于测试和调试

### 3. **可扩展性** 📈
- 易于添加新的生成器
- 支持自定义生成逻辑
- 可集成到 CI/CD 流程

### 4. **开发体验** 💫
- 不再依赖外部脚本
- IDE 友好的代码补全
- 统一的错误处理

## 迁移指南

### 从脚本执行迁移到类调用

**之前**:
```bash
dart test/script/api_gen_all.dart
```

**现在**:
```dart
final generator = ApiGenerator(config);
await generator.generateAll();
```

### 配置多模块

**之前**: 需要修改脚本中的硬编码路径

**现在**: 创建多个配置对象
```dart
final configs = [
  ApiGeneratorConfig(moduleName: 'Apply', ...),
  ApiGeneratorConfig(moduleName: 'User', ...),
  ApiGeneratorConfig(moduleName: 'Order', ...),
];
```

## 最佳实践

1. **模块命名**: 使用 PascalCase (如: `Apply`, `User`, `Order`)
2. **文件组织**: 每个模块使用独立的 YAML 文件
3. **批量生成**: 对于多模块项目，使用 `BatchApiGenerator`
4. **版本控制**: 提交配置文件，忽略生成的代码（可选）
5. **CI 集成**: 在构建流程中自动生成 API 代码

## 总结

参数化重构使 fx_dio_gen 从一个单一用途的工具变成了一个灵活、可扩展的 API 代码生成框架。现在可以轻松支持多模块项目，提供更好的开发体验和维护性。