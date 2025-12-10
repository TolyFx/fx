# 模板嵌入流程

## 概述

为了解决全局安装后无法找到 template.zip 文件的问题，我们将模板文件嵌入到可执行文件中。

## 嵌入流程

```mermaid
flowchart TD
    A[template.zip] --> B[tool/embed_template.dart]
    B --> C["读取 template.zip 字节数据"]
    C --> D["转换为 base64 编码"]
    D --> E["生成 Dart 代码"]
    E --> F[lib/embedded_template.dart]
    
    F --> G["ModuleCreator 导入"]
    G --> H["EmbeddedTemplate.getTemplateZip()"]
    H --> I["返回 Uint8List 数据"]
```

## 模板查找优先级

```mermaid
flowchart TD
    Start([开始查找模板]) --> A{1. 嵌入模板}
    A -->|成功| Success[✅ 返回模板数据]
    A -->|失败| B{2. 包资源}
    
    B -->|成功| Success
    B -->|失败| C{3. 全局安装目录}
    
    C -->|成功| Success
    C -->|失败| D{4. 脚本目录}
    
    D -->|成功| Success
    D -->|失败| E{5. 当前目录}
    
    E -->|成功| Success
    E -->|失败| F{6. 源目录}
    
    F -->|成功| Success
    F -->|失败| Fail[❌ 未找到模板]
```

## 构建流程

```mermaid
flowchart LR
    A[开发阶段] --> B[运行 embed_template.dart]
    B --> C[生成 embedded_template.dart]
    C --> D[清理缓存]
    D --> E[重新安装 CLI]
    E --> F[全局可用]
```

## 使用场景

```mermaid
flowchart TD
    User[用户] --> CLI{fx_cli validate}
    CLI --> Check[检查模板]
    
    Check --> Dev{开发环境?}
    Dev -->|是| Local[使用本地 template.zip]
    Dev -->|否| Embedded[使用嵌入模板]
    
    Local --> Result[✅ 显示模板信息]
    Embedded --> Result
    
    Check --> NotFound[❌ 未找到模板]
```

## 命令说明

### 嵌入模板
```bash
dart tool/embed_template.dart
```

### 清理缓存并重装
```bash
rmdir /s /q .dart_tool
dart pub get
dart pub global deactivate fx_cli
dart pub global activate --source path .
```

### 验证模板
```bash
fx_cli validate
```