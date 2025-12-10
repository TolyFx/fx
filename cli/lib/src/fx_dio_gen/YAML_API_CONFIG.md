# YAML API 配置文档

## 概述

使用 YAML 格式管理 API 配置，替代冗余的 raw.md，提供更好的可读性和可维护性。

## 优势

### 对比 raw.md

**raw.md 的问题**:
- ❌ 冗余数据多（重复的 headers）
- ❌ 可读性差（长 curl 命令）
- ❌ 难以维护（修改困难）
- ❌ 无法添加描述信息
- ❌ 无法分类管理

**apis.yaml 的优势**:
- ✅ 结构清晰，易于阅读
- ✅ 全局配置复用
- ✅ 支持描述和标签
- ✅ 易于版本控制
- ✅ 支持分类和搜索

## 文件结构

### apis.yaml

```yaml
# API 请求配置文件

apis:
  - name: applyTenancy          # API 名称（必需）
    description: 获取申请租约信息  # API 描述（必需）
    method: GET                  # HTTP 方法（必需）
    path: /api/apply/applyTenancy # API 路径（必需）
    params:                      # 查询参数（可选）
      hcl_id: 24434094
      unit_id: 201266
      house_id: 18087
    body:                        # 请求体（可选，POST 使用）
      key: value
    tags: [apply, tenancy]       # 标签（可选）

config:
  base_url: https://api.uhomes.com
  version: uhomes7.86
  headers:                       # 全局 headers
    X-Uhouzz-Cust-ID: "2501051"
    locale: "zh-cn"
```

## 字段说明

### API 配置 (apis)

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| name | String | ✅ | API 名称，用于生成枚举和方法名 |
| description | String | ✅ | API 描述，用于文档和注释 |
| method | String | ✅ | HTTP 方法：GET/POST/PUT/DELETE |
| path | String | ✅ | API 路径，不包含 base_url 和 version |
| params | Map | ❌ | 查询参数（GET）或表单参数 |
| body | Map | ❌ | 请求体参数（POST/PUT） |
| tags | List | ❌ | 标签，用于分类和筛选 |

### 全局配置 (config)

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| base_url | String | ✅ | API 基础 URL |
| version | String | ✅ | API 版本号 |
| headers | Map | ✅ | 全局请求头 |

### 特殊占位符

在 headers 中可以使用占位符：
- `{{timestamp}}`: 当前时间戳
- `{{signature}}`: 签名（生成时保留原样）

## 工作流程

### 1. 编辑 apis.yaml

```yaml
apis:
  - name: newApi
    description: 新的 API 接口
    method: GET
    path: /api/new/endpoint
    params:
      id: 123
    tags: [new]
```

### 2. 生成 curls.md

```bash
dart test/script/00_generate_curls.dart
```

生成的 curls.md:
```markdown
# newApi: 新的 API 接口
curl -H "X-Uhouzz-Cust-ID: 2501051" ... "https://api.uhomes.com/uhomes7.86/api/new/endpoint?id=123"
```

### 3. 继续后续流程

```bash
dart test/script/api_gen_all.dart
```

自动执行：
- Step 0: 生成 curls.md
- Step 1: 生成 API 文档
- Step 2: 生成 URL 枚举
- Step 3: 生成请求类
- Step 4: 生成测试用例

## 使用示例

### 添加 GET 请求

```yaml
- name: getUserInfo
  description: 获取用户信息
  method: GET
  path: /api/user/info
  params:
    user_id: 12345
  tags: [user, info]
```

### 添加 POST 请求

```yaml
- name: createOrder
  description: 创建订单
  method: POST
  path: /api/order/create
  body:
    house_id: 18087
    user_id: 12345
    amount: 1000
  tags: [order, create]
```

### 修改全局配置

```yaml
config:
  base_url: https://api-test.uhomes.com  # 切换到测试环境
  version: uhomes8.00                     # 升级版本
  headers:
    locale: "en-us"                       # 修改语言
```

## 最佳实践

### 1. 命名规范

- **name**: 使用驼峰命名，如 `getUserInfo`
- **path**: 使用 RESTful 风格，如 `/api/user/info`
- **tags**: 使用小写，如 `[user, info]`

### 2. 参数管理

- 使用真实的测试数据
- 保持参数值的一致性
- 添加注释说明特殊参数

### 3. 分类组织

使用 tags 进行分类：
```yaml
tags: [apply, tenancy]      # 申请相关
tags: [user, profile]       # 用户相关
tags: [order, payment]      # 订单相关
```

### 4. 版本控制

- 提交 apis.yaml 到版本控制
- 不提交生成的 curls.md（可选）
- 记录重要的配置变更

## 迁移指南

### 从 raw.md 迁移

1. **提取 URL 和参数**
```bash
# 原 raw.md
curl ... "https://api.uhomes.com/uhomes7.86/api/apply/template?house_id=18087&type=1"

# 转换为 yaml
- name: applyTemplate
  method: GET
  path: /api/apply/template
  params:
    house_id: 18087
    type: 1
```

2. **提取公共 headers**
```bash
# 原 raw.md（每个请求都重复）
-H "locale: zh-cn" -H "Version: 7.86" ...

# 转换为 yaml（只定义一次）
config:
  headers:
    locale: "zh-cn"
    Version: "7.86"
```

3. **添加描述信息**
```yaml
- name: applyTemplate
  description: 获取申请表单模板  # 新增描述
  tags: [apply, template]        # 新增标签
```

## 扩展功能

### 1. 环境切换

创建多个配置文件：
- `apis.yaml` - 生产环境
- `apis.dev.yaml` - 开发环境
- `apis.test.yaml` - 测试环境

### 2. 参数模板

定义可复用的参数：
```yaml
templates:
  common_house_params:
    house_id: 18087
    
apis:
  - name: api1
    params: 
      <<: *common_house_params
      extra_param: value
```

### 3. 条件生成

根据 tags 筛选生成：
```bash
# 只生成 apply 相关的 API
dart test/script/00_generate_curls.dart --tags=apply
```

## 故障排除

### 问题: YAML 解析错误

**解决**: 检查缩进（使用 2 空格）和引号

### 问题: 生成的 curl 不正确

**解决**: 检查 params 和 body 的格式

### 问题: headers 缺失

**解决**: 确保 config.headers 定义完整

## 总结

使用 YAML 配置 API 的优势：

1. **可读性**: 清晰的结构，易于理解
2. **可维护性**: 集中管理，修改方便
3. **可扩展性**: 支持描述、标签等元信息
4. **可复用性**: 全局配置，避免重复
5. **版本控制**: 友好的 diff，易于追踪变更

从 raw.md 迁移到 apis.yaml 是提升 API 管理效率的重要一步。
