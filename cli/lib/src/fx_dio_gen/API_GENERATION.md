# API 代码生成工具文档

## 概述

本项目提供了一套自动化的 API 代码生成工具链，可以从 curl 请求自动生成 API 枚举、请求类和测试用例。

## 工具链架构

```
raw.md (curl 请求)
    ↓
[Step 1] 生成请求文件
    ↓
api/**/*.md (API 文档)
    ↓
[Step 2] 生成 URL 枚举
    ↓
apply_url.dart (API 枚举)
    ↓
[Step 3] 生成请求类
    ↓
apply_request.dart (请求类)
    ↓
[Step 4] 生成测试用例
    ↓
apply_request_test.dart (测试文件)
```

## 快速开始

### 一键生成所有文件

```bash
dart test/script/api_gen_all.dart
```

这将依次执行所有步骤，生成完整的 API 代码。

### 分步执行

如果需要单独执行某个步骤：

```bash
# Step 1: 生成请求文件
dart test/script/01_generate_request_files.dart

# Step 2: 生成 URL 枚举
dart test/script/02_generate_url_enum.dart

# Step 3: 生成请求类
dart test/script/03_generate_request.dart

# Step 4: 生成测试用例
dart test/script/04_generate_test.dart
```

## 详细说明

### Step 1: 生成请求文件 (01_generate_request_files.dart)

**功能**: 从 `doc/dev/request/raw.md` 解析 curl 请求，生成结构化的 markdown 文档。

**输入**: `doc/dev/request/raw.md`
- 包含 curl 命令的原始文件

**输出**: `doc/dev/request/api/**/*.md`
- 按 API 路径组织的 markdown 文件
- 每个文件包含：URL、查询参数、请求体

**核心类**:
- `RequestInfo`: 存储请求信息（URL、方法、路径、参数等）
- `CurlParser`: 解析 curl 命令并生成文件

**文件命名规则**:
- 基于 API 路径的最后一部分
- 查询参数使用 `@` 分隔（如 `endpoint@param1=value1&param2=value2.md`）
- 重复的接口名会添加序号后缀（如 `endpoint_2.md`）

**示例输出**:
```markdown
# GET /api/apply/template

## URL
```
https://api.uhomes.com/uhomes2.00/api/apply/template?type=1&house_id=18087
```

## Query Parameters
```
type=1
house_id=18087
```
```

### Step 2: 生成 URL 枚举 (02_generate_url_enum.dart)

**功能**: 从 markdown 文件生成 Dart 枚举类，包含所有 API 端点。

**输入**: `doc/dev/request/api/**/*.md`

**输出**: `lib/src/repository/api/apply_url.dart`

**核心类**:
- `ApiEndpoint`: 存储 API 端点信息
- `UrlEnumGenerator`: 解析 markdown 并生成枚举

**生成的注解**:
- `@GET()` / `@POST()`: HTTP 方法
- `@ApiRequest()`: API 请求配置（必需参数、表单数据等）
- `@QueryParam()`: 查询参数定义
- `@BodyParam()`: 请求体参数定义

**类型推断规则**:
- 包含 `id` 或 `Id` → `int`
- 可解析为整数 → `int`
- `true`/`false` → `bool`
- 其他 → `String`

**示例输出**:
```dart
enum ApplyApi {
  @GET()
  @ApiRequest(
    requiredParams: ['type', 'house_id'],
  )
  @QueryParam(name: 'type', type: 'int')
  @QueryParam(name: 'house_id', type: 'int')
  applyTemplate("\$kUhomesApi/apply/template"),

  final String path;
  const ApplyApi(this.path);
}
```

### Step 3: 生成请求类 (03_generate_request.dart)

**功能**: 从 API 枚举生成请求类，包含所有 API 方法。

**输入**: `lib/src/repository/api/apply_url.dart`

**输出**: `lib/src/repository/api/apply_request.dart`

**核心类**:
- `ApiEndpointInfo`: 存储端点详细信息
- `RequestGenerator`: 解析枚举并生成请求类

**方法命名规则**:
- GET 请求: `get` + 首字母大写的端点名（如 `getApplyTemplate`）
- POST 请求: 直接使用端点名（如 `submitApply`）

**参数处理**:
- 必需参数: 位置参数
- 可选参数: 命名参数
- 参数名转换: snake_case → camelCase

**解密支持**:
- 读取 `lib/src/repository/api/decrypt_urls.dart`
- 自动为需要解密的接口添加 `decryptConvertor`

**示例输出**:
```dart
class ApplyRequest with UhomesRequest {
  Future<ApiRet<dynamic>> getApplyTemplate(int type, int houseId) async {
    Map<String, dynamic> params = {
      "type": type,
      "house_id": houseId,
    };
    return uhomes.get<dynamic>(
      ApplyApi.applyTemplate.path,
      queryParameters: params,
      convertor: (data) {
        return data;
      },
    );
  }
}
```

### Step 4: 生成测试用例 (04_generate_test.dart)

**功能**: 生成测试文件，包含所有 API 方法的测试用例。

**输出**: `test/request/apply_request_test.dart`

**测试特性**:
- 为每个 API 方法生成测试用例
- 自动将响应写入对应的 markdown 文件
- 使用预定义的测试参数

**辅助方法**:
- `_writeResultToMarkdown()`: 将 API 响应追加到 markdown 文档

**示例输出**:
```dart
test('getApplyTemplate should return data', () async {
  final result = await request.getApplyTemplate(testType, testHouseId);
  print(result.data);
  await _writeResultToMarkdown('applyTemplate', result.data);
  expect(result, isNotNull);
});
```

## 工作流程

### 1. 准备原始数据

在 `doc/dev/request/raw.md` 中添加 curl 请求：

```bash
curl "https://api.uhomes.com/uhomes2.00/api/apply/template?type=1&house_id=18087" -H "Authorization: Bearer token"
```

### 2. 运行生成工具

```bash
dart test/script/api_gen_all.dart
```

### 3. 查看生成的文件

- **API 文档**: `doc/dev/request/api/**/*.md`
- **URL 枚举**: `lib/src/repository/api/apply_url.dart`
- **请求类**: `lib/src/repository/api/apply_request.dart`
- **测试文件**: `test/request/apply_request_test.dart`

### 4. 运行测试

```bash
flutter test test/request/apply_request_test.dart
```

测试运行后，API 响应会自动追加到对应的 markdown 文档中。

### 5. 查看完整的 API 文档

每个 markdown 文件现在包含：
- URL
- 查询参数
- 请求体
- **响应数据**（测试后自动添加）

## 配置文件

### decrypt_urls.dart

定义需要解密的 API 端点：

```dart
const List<String> decryptUrls = [
  'applyTemplate',
  'agreement',
];
```

## 自定义参数

### 修改类名和输出路径

```bash
# 自定义 URL 枚举
dart test/script/02_generate_url_enum.dart CustomApi lib/custom_url.dart

# 自定义请求类
dart test/script/03_generate_request.dart CustomRequest lib/custom_url.dart lib/custom_request.dart

# 自定义测试文件
dart test/script/04_generate_test.dart test/custom_test.dart
```

## 最佳实践

1. **保持 raw.md 整洁**: 每行一个 curl 命令
2. **使用有意义的参数名**: 便于类型推断
3. **及时运行测试**: 确保生成的代码正确
4. **查看生成的文档**: 验证 API 响应格式
5. **版本控制**: 提交生成的代码和文档

## 故障排除

### 问题: 生成的枚举名重复

**解决**: 检查 markdown 文件名是否唯一，必要时手动重命名

### 问题: 参数类型推断错误

**解决**: 在 `02_generate_url_enum.dart` 的 `_inferType()` 方法中添加规则

### 问题: 测试无法找到 markdown 文件

**解决**: 确保文件名包含端点名称，或修改 `_writeResultToMarkdown()` 的匹配逻辑

### 问题: 解密不生效

**解决**: 检查 `decrypt_urls.dart` 是否包含对应的端点名

## 扩展功能

### 添加新的注解

在 `02_generate_url_enum.dart` 中扩展注解解析逻辑。

### 自定义响应类型

修改 `ApiEndpointInfo.responseType`，支持泛型类型。

### 添加模型生成

基于响应数据自动生成 Dart 模型类。

## 总结

这套工具链实现了从 curl 请求到完整 API 代码的自动化生成，大大提高了开发效率。通过标准化的流程和文档，团队可以快速理解和使用 API。
