import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'api_generator_config.dart';

// 全局配置：是否生成注释
const bool kGenerateComments = true;

class ApiEndpointInfo {
  final String name;
  final String path;
  final String httpMethod;
  final String description;
  final List<String> requiredParams;
  final List<ParamInfo> queryParams;
  final List<ParamInfo> bodyParams;
  final bool useFormData;
  final bool needsDecrypt;
  final String responseType;

  ApiEndpointInfo({
    required this.name,
    required this.path,
    required this.httpMethod,
    required this.description,
    this.requiredParams = const [],
    this.queryParams = const [],
    this.bodyParams = const [],
    this.useFormData = false,
    this.needsDecrypt = false,
    this.responseType = 'dynamic',
  });
}

class ParamInfo {
  final String name;
  final String type;
  final bool required;
  final String desc;

  ParamInfo({
    required this.name,
    required this.type,
    this.required = true,
    this.desc = '',
  });
}

class RequestGenerator {
  static List<ApiEndpointInfo> parseYaml(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final yamlContent = file.readAsStringSync();
    final yaml = loadYaml(yamlContent);

    final apis = yaml['apis'] as YamlList;
    final endpoints = <ApiEndpointInfo>[];

    for (final api in apis) {
      final apiMap = api as YamlMap;

      // 支持精简格式：name 作为 key，desc 作为 value
      String? name;
      String description = '';
      String? method;
      String? apiPath;

      // 检测精简格式
      for (final key in apiMap.keys) {
        final keyStr = key.toString();
        if (['GET', 'POST', 'PUT', 'DELETE'].contains(keyStr)) {
          method = keyStr;
          apiPath = apiMap[key].toString();
        } else if (!['params', 'form', 'body', 'decrypt'].contains(keyStr)) {
          name = keyStr;
          description = apiMap[key]?.toString() ?? '';
        }
      }

      // 兼容原格式
      name ??= apiMap['name'];
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
      final decrypt = apiMap['decrypt'] ?? false;

      final queryParams = <ParamInfo>[];
      final bodyParams = <ParamInfo>[];
      final requiredParams = <String>[];

      // 解析查询参数
      if (params != null) {
        params.forEach((key, value) {
          if (value is YamlMap) {
            final typeStr = value['type'].toString();
            final required = typeStr.endsWith('*');
            final optional = typeStr.endsWith('?');
            final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');

            queryParams.add(ParamInfo(
              name: key.toString(),
              type: cleanType,
              required: required || (!optional && !required),
              desc: value['desc']?.toString() ?? '',
            ));

            if (required || (!optional && !required)) {
              requiredParams.add(key.toString());
            }
          }
        });
      }

      // 解析请求体参数（body 或 form）
      final bodyData = form ?? body;
      if (bodyData != null) {
        bodyData.forEach((key, value) {
          if (value is YamlMap) {
            final typeStr = value['type'].toString();
            final cleanType = typeStr.replaceAll(RegExp(r'[*?]'), '');

            bodyParams.add(ParamInfo(
              name: key.toString(),
              type: cleanType,
              required: true,
              desc: value['desc']?.toString() ?? '',
            ));
          }
        });
      }

      if (name != null && method != null && apiPath != null) {
        endpoints.add(ApiEndpointInfo(
          name: name,
          path: apiPath,
          httpMethod: method,
          description: description,
          requiredParams: requiredParams,
          queryParams: queryParams,
          bodyParams: bodyParams,
          useFormData: form != null,
          needsDecrypt: decrypt == true,
          responseType: 'dynamic',
        ));
      }
    }

    return endpoints;
  }

  static void generateRequestClass(List<ApiEndpointInfo> endpoints, String className, String outputPath, [String enumClassName = 'ApplyApi']) {
    final buffer = StringBuffer();

    // 添加导入
    buffer.writeln("import 'package:app_env/app_env.dart';");
    buffer.writeln("import 'package:uhomes_assets/uhomes_assets.dart';");
    buffer.writeln("import '${enumClassName.toLowerCase().replaceAll('api', '')}_url.dart';");
    buffer.writeln();

    // 生成类
    buffer.writeln('class $className with UhomesRequest {');
    buffer.writeln();

    for (final endpoint in endpoints) {
      _generateMethod(buffer, endpoint);
      buffer.writeln();
    }

    buffer.writeln('}');

    // 写入文件
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(buffer.toString());
    print('Generated: $outputPath');
  }

  static void _generateMethod(StringBuffer buffer, ApiEndpointInfo endpoint) {
    final methodName = _generateMethodName(endpoint.name, endpoint.httpMethod);
    final needsDecrypt = endpoint.needsDecrypt;
    final camelCaseName = _toCamelCase(endpoint.name);

    // 生成注释
    if (kGenerateComments) {
      if (endpoint.description.isNotEmpty) {
        buffer.writeln('  /// ${endpoint.description}');
      }
      // 生成参数注释
      final allParams = [...endpoint.queryParams, ...endpoint.bodyParams];
      if (allParams.isNotEmpty) {
        buffer.writeln('  ///');
        for (final param in allParams) {
          if (param.desc.isNotEmpty) {
            final camelName = _toCamelCase(param.name);
            buffer.writeln('  /// [$camelName]: ${param.desc}');
          }
        }
      }
    }

    // 生成方法签名
    final allParams = <String>[];

    // 查询参数
    for (final param in endpoint.queryParams) {
      final camelName = _toCamelCase(param.name);
      final isRequired = endpoint.requiredParams.contains(param.name);
      if (isRequired) {
        allParams.add('required ${_dartType(param.type)} $camelName');
      } else {
        allParams.add('${_dartType(param.type)}? $camelName');
      }
    }

    // 请求体参数
    for (final param in endpoint.bodyParams) {
      final camelName = _toCamelCase(param.name);
      allParams.add('required ${_dartType(param.type)} $camelName');
    }

    if (allParams.isNotEmpty) {
      buffer.write('  Future<ApiRet<${endpoint.responseType}>> $methodName({');
      buffer.write('\n    ${allParams.join(',\n    ')},\n  ');
      buffer.writeln('}) async {');
    } else {
      buffer.writeln('  Future<ApiRet<${endpoint.responseType}>> $methodName() async {');
    }

    // 生成方法体
    if (endpoint.httpMethod == 'GET' && endpoint.queryParams.isNotEmpty) {
      buffer.writeln('    Map<String, dynamic> params = {');
      for (final param in endpoint.queryParams) {
        final camelName = _toCamelCase(param.name);
        if (endpoint.requiredParams.contains(param.name)) {
          buffer.writeln('      "${param.name}": $camelName,');
        } else {
          buffer.writeln('      if ($camelName != null) "${param.name}": $camelName,');
        }
      }
      buffer.writeln('    };');

      buffer.writeln('    return uhomes.get<${endpoint.responseType}>(');
      buffer.writeln('      ApplyApi.$camelCaseName.path,');
      if (needsDecrypt) {
        buffer.writeln('      decryptConvertor: EncryptUtil.aesDecrypt,');
      }
      buffer.writeln('      queryParameters: params,');
      buffer.writeln('      convertor: (data) {');
      buffer.writeln('        return data;');
      buffer.writeln('      },');
      buffer.writeln('    );');
    } else if (endpoint.httpMethod == 'POST') {
      if (endpoint.queryParams.isNotEmpty) {
        buffer.writeln('    Map<String, dynamic> queryParams = {');
        for (final param in endpoint.queryParams) {
          final camelName = _toCamelCase(param.name);
          if (endpoint.requiredParams.contains(param.name)) {
            buffer.writeln('      "${param.name}": $camelName,');
          } else {
            buffer.writeln('      if ($camelName != null) "${param.name}": $camelName,');
          }
        }
        buffer.writeln('    };');
      }

      if (endpoint.bodyParams.isNotEmpty) {
        buffer.writeln('    Map<String, dynamic> bodyParams = {');
        for (final param in endpoint.bodyParams) {
          final camelName = _toCamelCase(param.name);
          buffer.writeln('      "${param.name}": $camelName,');
        }
        buffer.writeln('    };');
      }

      buffer.writeln('    return uhomes.post<${endpoint.responseType}>(');
      buffer.writeln('      ApplyApi.$camelCaseName.path,');
      if (endpoint.queryParams.isNotEmpty) {
        buffer.writeln('      queryParameters: queryParams,');
      }
      if (endpoint.bodyParams.isNotEmpty) {
        if (endpoint.useFormData) {
          buffer.writeln('      data: FormData.fromMap(bodyParams),');
        } else {
          buffer.writeln('      data: bodyParams,');
        }
      }
      buffer.writeln('      convertor: (data) {');
      buffer.writeln('        return data;');
      buffer.writeln('      },');
      buffer.writeln('    );');
    } else {
      // 简单的 GET 请求，无参数
      buffer.writeln('    return uhomes.get<${endpoint.responseType}>(');
      buffer.writeln('      ApplyApi.$camelCaseName.path,');
      if (needsDecrypt) {
        buffer.writeln('      decryptConvertor: EncryptUtil.aesDecrypt,');
      }
      buffer.writeln('      convertor: (data) {');
      buffer.writeln('        return data;');
      buffer.writeln('      },');
      buffer.writeln('    );');
    }

    buffer.writeln('  }');
  }

  static String _generateMethodName(String endpointName, String httpMethod) {
    final camelName = _toCamelCase(endpointName);
    if (httpMethod == 'GET') {
      return 'get${camelName[0].toUpperCase()}${camelName.substring(1)}';
    }
    return camelName;
  }

  static String _dartType(String type) {
    switch (type) {
      case 'int':
        return 'int';
      case 'bool':
        return 'bool';
      case 'String':
      default:
        return 'String';
    }
  }

  static String _toCamelCase(String snakeCase) {
    final parts = snakeCase.split('_');
    if (parts.length <= 1) return snakeCase;

    return parts[0] + parts.skip(1).map((part) =>
        part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1)
    ).join('');
  }
}


class RequestClassGenerator {
  final ApiGeneratorConfig config;

  const RequestClassGenerator(this.config);

  Future<void> generate() async {
    print('Generating Request class...');
    print('Class name: ${config.requestClassName}');
    print('Output path: ${config.requestFilePath}');
    print('');

    final endpoints = RequestGenerator.parseYaml(config.yamlPath);
    print('Found ${endpoints.length} API endpoints:');

    for (final endpoint in endpoints) {
      print('  - ${endpoint.name}: ${endpoint.httpMethod} ${endpoint.path}');
    }
    print('');

    RequestGenerator.generateRequestClass(endpoints, config.requestClassName, config.requestFilePath, config.enumClassName);

    print('Request class generated successfully!');
  }
}

void main([List<String>? args]) {
  args ??= [];

  try {
    String className = 'ApplyRequest';
    String outputPath = path.join('lib', 'src', 'repository', 'api', 'apply_request.dart');

    if (args.isNotEmpty) {
      className = args[0];
    }
    if (args.length > 1) {
      outputPath = args[1];
    }

    final config = ApiGeneratorConfig(
      moduleName: className.replaceAll('Request', ''),
      yamlPath: path.join('doc', 'dev', 'request', 'apis.yaml'),
      outputDir: path.dirname(outputPath),
      requestClassName: className,
    );

    final generator = RequestClassGenerator(config);
    generator.generate();

  } catch (e) {
    print('Error: $e');
  }
}
