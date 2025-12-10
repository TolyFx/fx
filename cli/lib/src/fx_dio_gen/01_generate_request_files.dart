import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'api_generator_config.dart';

class RequestInfo {
  final String url;
  final String method;
  final String path;
  final String description;
  final Map<String, String> headers;
  final Map<String, String> queryParams;
  final Map<String, String> queryParamsDesc;
  final Map<String, String> formParams;
  final Map<String, String> formParamsDesc;
  final String? body;

  RequestInfo({
    required this.url,
    required this.method,
    required this.path,
    this.description = '',
    required this.headers,
    required this.queryParams,
    this.queryParamsDesc = const {},
    this.formParams = const {},
    this.formParamsDesc = const {},
    this.body,
  });

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# ${method.toUpperCase()} ${path}');
    buffer.writeln();

    if (description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }

    buffer.writeln('## URL');
    buffer.writeln('```');
    buffer.writeln(url);
    buffer.writeln('```');
    buffer.writeln();

    if (queryParams.isNotEmpty) {
      buffer.writeln('## Query Parameters');
      buffer.writeln('```');
      queryParams.forEach((key, value) {
        final desc = queryParamsDesc[key];
        if (desc != null && desc.isNotEmpty) {
          buffer.writeln('$key=$value  # $desc');
        } else {
          buffer.writeln('$key=$value');
        }
      });
      buffer.writeln('```');
      buffer.writeln();
    }

    if (formParams.isNotEmpty) {
      buffer.writeln('## Form Data');
      buffer.writeln('```');
      formParams.forEach((key, value) {
        final desc = formParamsDesc[key];
        if (desc != null && desc.isNotEmpty) {
          buffer.writeln('$key=$value  # $desc');
        } else {
          buffer.writeln('$key=$value');
        }
      });
      buffer.writeln('```');
      buffer.writeln();
    }

    if (body != null && body!.isNotEmpty) {
      buffer.writeln('## Request Body');
      buffer.writeln('```');
      buffer.writeln(body);
      buffer.writeln('```');
      buffer.writeln();
    }

    return buffer.toString();
  }
}

class CurlParser {
  static List<RequestInfo> parseFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final content = file.readAsStringSync();
    final curlCommands = content
        .split('\n')
        .where((line) => line.trim().startsWith('curl'))
        .toList();

    return curlCommands.map(parseCurlCommand).toList();
  }

  static RequestInfo parseCurlCommand(String curlCommand) {
    final headers = <String, String>{};
    final queryParams = <String, String>{};
    String? body;
    String url = '';
    String method = 'GET';

    final urlMatch = RegExp(r'"(https?://[^"]+)"').firstMatch(curlCommand);
    if (urlMatch != null) {
      url = urlMatch.group(1)!;
    }

    final uri = Uri.parse(url);
    final path = uri.path;
    queryParams.addAll(uri.queryParameters);

    final headerMatches = RegExp(r'-H "([^:]+):\s*([^"]*)"').allMatches(curlCommand);
    for (final match in headerMatches) {
      headers[match.group(1)!] = match.group(2)!;
    }

    if (curlCommand.contains('--data')) {
      method = 'POST';
      final dataMatch = RegExp(r'--data "([^"]*)"').firstMatch(curlCommand);
      if (dataMatch != null) {
        body = dataMatch.group(1);
      }
    }

    return RequestInfo(
      url: url,
      method: method,
      path: path,
      headers: headers,
      queryParams: queryParams,
      body: body,
    );
  }

  static List<RequestInfo> parseYaml(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('File not found: $filePath');
    }

    final yamlContent = file.readAsStringSync();
    final yaml = loadYaml(yamlContent);

    final apis = yaml['apis'] as YamlList;
    final config = yaml['config'] as YamlMap;
    final baseUrl = config['base_url'];

    final requests = <RequestInfo>[];

    for (final api in apis) {
      final apiMap = api as YamlMap;

      // 支持精简格式
      String? method;
      String? apiPath;
      String description = '';

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

      final params = apiMap['params'] as YamlMap?;
      final body = apiMap['body'] as YamlMap?;
      final form = apiMap['form'] as YamlMap?;

      final queryParams = <String, String>{};
      final queryParamsDesc = <String, String>{};
      final formParams = <String, String>{};
      final formParamsDesc = <String, String>{};
      String? bodyStr;

      // 提取查询参数
      if (params != null) {
        params.forEach((key, value) {
          if (value is YamlMap && value.containsKey('test')) {
            queryParams[key.toString()] = value['test'].toString();
            if (value.containsKey('desc')) {
              queryParamsDesc[key.toString()] = value['desc'].toString();
            }
          }
        });
      }

      // 提取 form 参数
      if (form != null) {
        form.forEach((key, value) {
          if (value is YamlMap && value.containsKey('test')) {
            formParams[key.toString()] = value['test'].toString();
            if (value.containsKey('desc')) {
              formParamsDesc[key.toString()] = value['desc'].toString();
            }
          }
        });
      } else if (body != null) {
        final bodyParams = <String>[];
        body.forEach((key, value) {
          if (value is YamlMap && value.containsKey('test')) {
            bodyParams.add('$key=${value['test']}');
          }
        });
        bodyStr = bodyParams.join('&');
      }

      if (method != null && apiPath != null) {
        final url = '$baseUrl$apiPath' + (queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '');

        requests.add(RequestInfo(
          url: url,
          method: method,
          path: apiPath,
          description: description,
          headers: {},
          queryParams: queryParams,
          queryParamsDesc: queryParamsDesc,
          formParams: formParams,
          formParamsDesc: formParamsDesc,
          body: bodyStr,
        ));
      }
    }

    return requests;
  }

  static void generateRequestFiles(List<RequestInfo> requests, [String? customDocsDir]) {
    final baseDir = customDocsDir ?? path.join('doc', 'dev', 'request', 'api');

    // 清空目录
    final apiDir = Directory(baseDir);
    if (apiDir.existsSync()) {
      apiDir.deleteSync(recursive: true);
      print('Cleared existing directory: $baseDir');
    }

    final pathCounts = <String, int>{};

    for (final request in requests) {
      // 提取 API 路径，去掉 /uhomesX.XX 前缀
      String apiPath = request.path.replaceFirst(RegExp(r'/uhomes\d+\.\d+'), '');
      if (apiPath.startsWith('/')) {
        apiPath = apiPath.substring(1);
      }

      // 获取接口名（路径的最后一部分）
      final pathParts = apiPath.split('/');
      final endpointName = pathParts.last;

      // 构建查询参数字符串
      String queryString = '';
      if (request.queryParams.isNotEmpty) {
        queryString = '@' + request.queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
      }

      // 创建文件夹路径（去掉最后的接口名）
      final folderParts = pathParts.sublist(0, pathParts.length - 1);
      final folderPath = folderParts.isEmpty ? baseDir : path.joinAll([baseDir, ...folderParts]);
      final folder = Directory(folderPath);
      folder.createSync(recursive: true);

      // 生成文件名：接口名 + 查询参数（使用 @ 代替 ?）
      final baseFileName = endpointName + queryString;
      pathCounts[baseFileName] = (pathCounts[baseFileName] ?? 0) + 1;
      final count = pathCounts[baseFileName]!;

      final fileName = count > 1 ? '${baseFileName}_$count.md' : '$baseFileName.md';
      final filePath = path.join(folderPath, fileName);

      // 写入文件
      final file = File(filePath);
      file.writeAsStringSync(request.toMarkdown());

      print('Created: $filePath');
    }
  }
}


class RequestFileGenerator {
  final ApiGeneratorConfig config;

  const RequestFileGenerator(this.config);

  Future<void> generate() async {
    final requests = CurlParser.parseYaml(config.yamlPath);
    print('Parsing ${requests.length} requests...\n');

    CurlParser.generateRequestFiles(requests, config.docsDir);

    print('\nGenerated request files successfully!');
  }
}

void main() {
  try {
    final config = ApiGeneratorConfig(
      moduleName: 'Apply',
      yamlPath: path.join('doc', 'dev', 'request', 'apis.yaml'),
      outputDir: 'lib/src/repository/api',
    );

    final generator = RequestFileGenerator(config);
    generator.generate();

  } catch (e) {
    print('Error: $e');
  }
}
