import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'api_generator_config.dart';

// 全局配置：是否生成注释
const bool kGenerateComments = true;

class ParamInfo {
  final String type;
  final bool required;
  final String testValue;
  final String desc;

  ParamInfo({
    required this.type,
    required this.required,
    required this.testValue,
    this.desc = '',
  });
}

class ApiEndpoint {
  final String name;
  final String path;
  final String method;
  final String description;
  final Map<String, ParamInfo> params;
  final Map<String, ParamInfo>? bodyParams;

  ApiEndpoint({
    required this.name,
    required this.path,
    required this.method,
    required this.description,
    required this.params,
    this.bodyParams,
  });
}

// class UrlEnumGenerator {
//   static List<ApiEndpoint> parseYaml(String filePath) {
//     final file = File(filePath);
//     if (!file.existsSync()) {
//       throw Exception('File not found: $filePath');
//     }
//
//     final yamlContent = file.readAsStringSync();
//     final yaml = loadYaml(yamlContent);
//
//     final apis = yaml['apis'] as YamlList;
//     final config = yaml['config'] as YamlMap;
//     final baseUrl = config['base_url'];
//
//     final endpoints = <ApiEndpoint>[];
//
//     for (final api in apis) {
//       final apiMap = api as YamlMap;
//
//       // 支持精简格式
//       String? name;
//       String description = '';
//       String? method;
//       String? apiPath;
//
//       for (final key in apiMap.keys) {
//         final keyStr = key.toString();
//         if (['GET', 'POST', 'PUT', 'DELETE'].contains(keyStr)) {
//           method = keyStr;
//           apiPath = apiMap[key].toString();
//         } else if (!['params', 'form', 'body', 'decrypt'].contains(keyStr)) {
//           name = keyStr;
//           description = apiMap[key]?.toString() ?? '';
//         }
//       }
//
//       name ??= apiMap['name'];
//       method ??= apiMap['method'];
//       apiPath ??= apiMap['path'];
//       description = description.isEmpty ? (apiMap['desc']?.toString() ?? '') : description;
//
//       // 如果没有 name 或 name 是 'desc'，从路径提取最后一段
//       if ((name == null || name == 'desc') && apiPath != null) {
//         final pathParts = apiPath.split('/');
//         name = pathParts.last;
//       }
//       final params = apiMap['params'] as YamlMap?;
//       final body = apiMap['body'] as YamlMap?;
//
//       final paramInfos = <String, ParamInfo>{};
//       Map<String, ParamInfo>? bodyParamInfos;
//
//       // 提取参数信息（类型、必填、测试值）
//       if (params != null) {
//         params.forEach((key, value) {
//           if (value is YamlMap) {
//             final typeStr = value['type'].toString();
//             final required = typeStr.endsWith('*');
//             final optional = typeStr.endsWith('?');
//             final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');
//
//             paramInfos[key.toString()] = ParamInfo(
//               type: cleanType,
//               required: required || (!optional && !required),
//               testValue: value['test'].toString(),
//               desc: value['desc']?.toString() ?? '',
//             );
//           }
//         });
//       }
//
//       if (body != null) {
//         bodyParamInfos = <String, ParamInfo>{};
//         body.forEach((key, value) {
//           if (value is YamlMap) {
//             final typeStr = value['type'].toString();
//             final required = typeStr.endsWith('*');
//             final optional = typeStr.endsWith('?');
//             final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');
//
//             bodyParamInfos![key.toString()] = ParamInfo(
//               type: cleanType,
//               required: required || (!optional && !required),
//               testValue: value['test'].toString(),
//               desc: value['desc']?.toString() ?? '',
//             );
//           }
//         });
//       }
//
//       // 构建 URL（使用测试值）
//       final queryStr = paramInfos.entries.map((e) => '${e.key}=${e.value.testValue}').join('&');
//       final url = '$baseUrl$apiPath' + (queryStr.isNotEmpty ? '?$queryStr' : '');
//
//       if (name != null && method != null && apiPath != null) {
//         endpoints.add(ApiEndpoint(
//           name: name,
//           path: url,
//           method: method,
//           description: description,
//           params: paramInfos,
//           bodyParams: bodyParamInfos,
//         ));
//       }
//     }
//
//     return endpoints;
//   }
//
//   static String _generateMethodName(String endpointName, String method) {
//     if (method.toLowerCase() == 'get') {
//       return 'get${endpointName[0].toUpperCase()}${endpointName.substring(1)}';
//     } else if (method.toLowerCase() == 'post') {
//       return endpointName;
//     }
//     return endpointName;
//   }
//
//   static String _toCamelCase(String name) {
//     // 将下划线命名转换为驼峰命名
//     if (!name.contains('_')) return name;
//
//     final parts = name.split('_');
//     final buffer = StringBuffer(parts[0]);
//
//     for (int i = 1; i < parts.length; i++) {
//       if (parts[i].isNotEmpty) {
//         buffer.write(parts[i][0].toUpperCase());
//         if (parts[i].length > 1) {
//           buffer.write(parts[i].substring(1));
//         }
//       }
//     }
//
//     return buffer.toString();
//   }
//
//   static String _inferType(String key, String value) {
//     // 根据参数名和值推断类型
//     if (key.contains('id') || key.contains('Id')) {
//       return 'int';
//     }
//     if (key == 'type' && int.tryParse(value) != null) {
//       return 'int';
//     }
//     if (int.tryParse(value) != null) {
//       return 'int';
//     }
//     if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
//       return 'bool';
//     }
//     return 'String';
//   }
//
//   static void generateUrlEnum(List<ApiEndpoint> endpoints, String className, String outputPath) {
//     final buffer = StringBuffer();
//
//     // 添加导入
//     buffer.writeln("import 'package:app_env/app_env.dart';");
//     buffer.writeln();
//
//     // 生成枚举类
//     buffer.writeln('enum $className {');
//
//     for (int i = 0; i < endpoints.length; i++) {
//       final endpoint = endpoints[i];
//       final isLast = i == endpoints.length - 1;
//
//       // 转换 URL 并分离查询参数
//       final convertedPath = endpoint.path.replaceFirst(RegExp(r'https://api\.uhomes\.com/uhomes\d+\.\d+/api'), '\$kUhomesApi');
//       final pathWithoutQuery = convertedPath.split('?')[0];
//
//       // 生成注释
//       if (kGenerateComments && endpoint.description.isNotEmpty) {
//         buffer.writeln('  /// ${endpoint.description}');
//       }
//
//       // 生成枚举值（将下划线命名转换为驼峰命名）
//       final camelCaseName = _toCamelCase(endpoint.name);
//       buffer.write('  $camelCaseName("${pathWithoutQuery}")');
//       buffer.writeln(isLast ? ';' : ',');
//     }
//
//     buffer.writeln();
//     // 添加构造函数和属性
//     buffer.writeln('  final String path;');
//     buffer.writeln();
//     buffer.writeln('  const $className(this.path);');
//     buffer.writeln('}');
//
//     // 写入文件
//     final file = File(outputPath);
//     file.parent.createSync(recursive: true);
//     file.writeAsStringSync(buffer.toString());
//     print('Generated: $outputPath');
//   }
// }


class UrlEnumGenerator {
  final ApiGeneratorConfig config;

  const UrlEnumGenerator(this.config);

  Future<void> generate() async {
    print('Generating URL enum...');
    print('Class name: ${config.enumClassName}');
    print('Output path: ${config.enumFilePath}');
    print('');

    // 解析 YAML 文件
    final endpoints = _parseYaml(config.yamlPath);
    print('Found ${endpoints.length} API endpoints:');

    for (final endpoint in endpoints) {
      print('  - ${endpoint.name}: ${endpoint.method.toUpperCase()} ${endpoint.path}');
    }
    print('');

    // 生成枚举文件
    _generateUrlEnum(endpoints, config.enumClassName, config.enumFilePath);

    print('URL enum generated successfully!');
  }

  static List<ApiEndpoint> _parseYaml(String filePath) {
    // 移动原 parseYaml 方法内容到这里
    return UrlEnumGeneratorStatic.parseYaml(filePath);
  }

  static void _generateUrlEnum(List<ApiEndpoint> endpoints, String className, String outputPath) {
    // 移动原 generateUrlEnum 方法内容到这里
    UrlEnumGeneratorStatic.generateUrlEnum(endpoints, className, outputPath);
  }
}

class UrlEnumGeneratorStatic {
  static List<ApiEndpoint> parseYaml(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final yamlContent = file.readAsStringSync();
    final yaml = loadYaml(yamlContent);

    final apis = yaml['apis'] as YamlList;
    final config = yaml['config'] as YamlMap;
    final baseUrl = config['base_url'];

    final endpoints = <ApiEndpoint>[];

    for (final api in apis) {
      final apiMap = api as YamlMap;

      // 支持精简格式
      String? name;
      String description = '';
      String? method;
      String? apiPath;

      for (final key in apiMap.keys) {
        final keyStr = key.toString();
        if (['GET', 'POST', 'PUT', 'DELETE'].contains(keyStr)) {
          method = keyStr;
          apiPath = apiMap[key].toString();
        } else if (!['params', 'form', 'body', 'decrypt', 'name', 'method', 'path', 'desc'].contains(keyStr)) {
          description = apiMap[key]?.toString() ?? '';
        }
      }

      method ??= apiMap['method'];
      apiPath ??= apiMap['path'];
      description = description.isEmpty ? (apiMap['desc']?.toString() ?? '') : description;

      // 如果没有 name 或 name 是 'desc'，从路径提取最后一段
      if ((name == null || name == 'desc') && apiPath != null) {
        final pathParts = apiPath.split('/');
        name = pathParts.last;
      }
      final params = apiMap['params'] as YamlMap?;
      final body = apiMap['body'] as YamlMap?;
      final form = apiMap['form'] as YamlMap?;

      final paramInfos = <String, ParamInfo>{};
      Map<String, ParamInfo>? bodyParamInfos;

      // 提取参数信息（类型、必填、测试值）
      if (params != null) {
        params.forEach((key, value) {
          if (value is YamlMap) {
            final typeStr = value['type'].toString();
            final required = typeStr.endsWith('*');
            final optional = typeStr.endsWith('?');
            final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');

            paramInfos[key.toString()] = ParamInfo(
              type: cleanType,
              required: required || (!optional && !required),
              testValue: value['test'].toString(),
              desc: value['desc']?.toString() ?? '',
            );
          }
        });
      }

      if (body != null) {
        bodyParamInfos = <String, ParamInfo>{};
        body.forEach((key, value) {
          if (value is YamlMap) {
            final typeStr = value['type'].toString();
            final required = typeStr.endsWith('*');
            final optional = typeStr.endsWith('?');
            final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');

            bodyParamInfos![key.toString()] = ParamInfo(
              type: cleanType,
              required: required || (!optional && !required),
              testValue: value['test'].toString(),
              desc: value['desc']?.toString() ?? '',
            );
          }
        });
      }

      // 构建 URL（使用测试值）
      final queryStr = paramInfos.entries.map((e) => '${e.key}=${e.value.testValue}').join('&');
      final url = '$baseUrl$apiPath' + (queryStr.isNotEmpty ? '?$queryStr' : '');

      if (name != null && method != null && apiPath != null) {
        endpoints.add(ApiEndpoint(
          name: name,
          path: url,
          method: method,
          description: description,
          params: paramInfos,
          bodyParams: bodyParamInfos,
        ));
      }
    }

    return endpoints;
  }

  static void generateUrlEnum(List<ApiEndpoint> endpoints, String className, String outputPath) {
    final buffer = StringBuffer();

    // 添加导入
    buffer.writeln("import 'package:app_env/app_env.dart';");
    buffer.writeln();

    // 生成枚举类
    buffer.writeln('enum $className {');

    for (int i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      final isLast = i == endpoints.length - 1;

      // 转换 URL 并分离查询参数
      final convertedPath = endpoint.path.replaceFirst(RegExp(r'https://api\.uhomes\.com/uhomes\d+\.\d+/api'), '\$kUhomesApi');
      final pathWithoutQuery = convertedPath.split('?')[0];

      // 生成注释
      if (kGenerateComments && endpoint.description.isNotEmpty) {
        buffer.writeln('  /// ${endpoint.description}');
      }

      // 生成枚举值（将下划线命名转换为驼峰命名）
      final camelCaseName = _toCamelCase(endpoint.name);
      buffer.write('  $camelCaseName("${pathWithoutQuery}")');
      buffer.writeln(isLast ? ';' : ',');
    }

    buffer.writeln();
    // 添加构造函数和属性
    buffer.writeln('  final String path;');
    buffer.writeln();
    buffer.writeln('  const $className(this.path);');
    buffer.writeln('}');

    // 写入文件
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(buffer.toString());
    print('Generated: $outputPath');
  }

  static String _toCamelCase(String name) {
    // 将下划线命名转换为驼峰命名
    if (!name.contains('_')) return name;

    final parts = name.split('_');
    final buffer = StringBuffer(parts[0]);

    for (int i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        if (parts[i].length > 1) {
          buffer.write(parts[i].substring(1));
        }
      }
    }

    return buffer.toString();
  }
}

void main([List<String>? args]) {
  args ??= [];
  try {
    // 默认参数
    String className = 'ApplyApi';
    String outputPath = path.join('lib', 'src', 'repository', 'api', 'apply_url.dart');

    // 解析命令行参数
    if (args.isNotEmpty) {
      className = args[0];
    }
    if (args.length > 1) {
      outputPath = args[1];
    }

    final config = ApiGeneratorConfig(
      moduleName: className.replaceAll('Api', ''),
      yamlPath: path.join('doc', 'dev', 'request', 'apis.yaml'),
      outputDir: path.dirname(outputPath),
      enumClassName: className,
    );

    final generator = UrlEnumGenerator(config);
    generator.generate();

  } catch (e) {
    print('Error: $e');
  }
}
